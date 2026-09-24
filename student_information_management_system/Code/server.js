require('dotenv').config();
const path = require('path');
const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');

const app = express();
const PORT = Number(process.env.PORT || 3000);

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'sims_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  namedPlaceholders: true
});

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

function cleanStudentInput(body) {
  const fields = [
    'roll_no', 'first_name', 'last_name', 'email', 'phone', 'dob',
    'gender', 'admission_date', 'program_id', 'status', 'address_line',
    'city', 'state', 'pin_code'
  ];
  return Object.fromEntries(fields.map(k => [k, body[k] ?? null]));
}

app.get('/api/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ ok: true, database: 'connected' });
  } catch (err) {
    res.status(503).json({ ok: false, database: 'unavailable', message: err.message });
  }
});

app.get('/api/dashboard', async (_req, res) => {
  try {
    const [[totals]] = await pool.query(`
      SELECT
        (SELECT COUNT(*) FROM students) AS students,
        (SELECT COUNT(*) FROM departments) AS departments,
        (SELECT COUNT(*) FROM programs) AS programs,
        (SELECT COUNT(*) FROM courses) AS courses,
        (SELECT COUNT(*) FROM enrollments) AS enrollments
    `);
    const [recent] = await pool.query(`
      SELECT s.student_id, s.roll_no,
             CONCAT(s.first_name, ' ', s.last_name) AS name,
             p.program_name, d.dept_code, s.status
      FROM students s
      JOIN programs p ON p.program_id = s.program_id
      JOIN departments d ON d.department_id = p.department_id
      ORDER BY s.student_id DESC
      LIMIT 8
    `);
    res.json({ totals, recent });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/students', async (req, res) => {
  try {
    const search = String(req.query.search || '').trim();
    const status = String(req.query.status || '').trim();
    const limit = Math.min(Math.max(Number(req.query.limit || 100), 1), 500);
    const params = [];
    const where = [];

    if (search) {
      const like = `%${search}%`;
      where.push(`(s.roll_no LIKE ? OR s.first_name LIKE ? OR s.last_name LIKE ? OR s.email LIKE ?)`);
      params.push(like, like, like, like);
    }
    if (status) {
      where.push('s.status = ?');
      params.push(status);
    }

    const sql = `
      SELECT s.student_id, s.roll_no, s.first_name, s.last_name, s.email,
             s.phone, s.dob, s.gender, s.admission_date, s.status,
             s.address_line, s.city, s.state, s.pin_code,
             p.program_id, p.program_name, d.department_id, d.dept_code, d.dept_name
      FROM students s
      JOIN programs p ON p.program_id = s.program_id
      JOIN departments d ON d.department_id = p.department_id
      ${where.length ? `WHERE ${where.join(' AND ')}` : ''}
      ORDER BY s.student_id DESC
      LIMIT ${limit}
    `;
    const [rows] = await pool.query(sql, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/students', async (req, res) => {
  const data = cleanStudentInput(req.body);
  try {
    const [result] = await pool.execute(`
      INSERT INTO students
      (roll_no, first_name, last_name, email, phone, dob, gender, admission_date,
       program_id, status, address_line, city, state, pin_code)
      VALUES (:roll_no, :first_name, :last_name, :email, :phone, :dob, :gender,
              :admission_date, :program_id, COALESCE(:status, 'Active'),
              :address_line, COALESCE(:city, 'Nagpur'), :state, :pin_code)
    `, data);
    const [rows] = await pool.query('SELECT * FROM students WHERE student_id = ?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.put('/api/students/:id', async (req, res) => {
  const data = cleanStudentInput(req.body);
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) return res.status(400).json({ error: 'Invalid student id.' });
  try {
    const [result] = await pool.execute(`
      UPDATE students SET
        roll_no=:roll_no, first_name=:first_name, last_name=:last_name,
        email=:email, phone=:phone, dob=:dob, gender=:gender,
        admission_date=:admission_date, program_id=:program_id, status=:status,
        address_line=:address_line, city=:city, state=:state, pin_code=:pin_code
      WHERE student_id=:student_id
    `, { ...data, student_id: id });
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Student not found.' });
    const [rows] = await pool.query('SELECT * FROM students WHERE student_id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.delete('/api/students/:id', async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) return res.status(400).json({ error: 'Invalid student id.' });
  try {
    const [result] = await pool.execute('DELETE FROM students WHERE student_id = ?', [id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Student not found.' });
    res.json({ message: 'Student deleted successfully.' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.get('/api/departments', async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT d.department_id, d.dept_code, d.dept_name, d.location,
             COUNT(s.student_id) AS student_count
      FROM departments d
      LEFT JOIN programs p ON p.department_id = d.department_id
      LEFT JOIN students s ON s.program_id = p.program_id
      GROUP BY d.department_id, d.dept_code, d.dept_name, d.location
      ORDER BY student_count DESC, d.dept_code
    `);
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/programs', async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT p.program_id, p.program_code, p.program_name, p.duration_years,
             d.department_id, d.dept_code, d.dept_name
      FROM programs p JOIN departments d ON d.department_id = p.department_id
      ORDER BY p.program_name
    `);
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/courses', async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT c.course_id, c.course_code, c.course_name, c.credits,
             p.program_name, d.dept_code
      FROM courses c
      JOIN programs p ON p.program_id = c.program_id
      JOIN departments d ON d.department_id = p.department_id
      ORDER BY c.course_code
    `);
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/enrollments', async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT e.enrollment_id, s.roll_no,
             CONCAT(s.first_name, ' ', s.last_name) AS student_name,
             c.course_code, c.course_name,
             co.academic_year, co.semester, e.grade, e.status
      FROM enrollments e
      JOIN students s ON s.student_id = e.student_id
      JOIN course_offerings co ON co.offering_id = e.offering_id
      JOIN courses c ON c.course_id = co.course_id
      ORDER BY e.enrollment_id DESC
      LIMIT 200
    `);
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/reports/department-strength', async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT d.dept_code, d.dept_name, COUNT(s.student_id) AS student_count
      FROM departments d
      LEFT JOIN programs p ON p.department_id = d.department_id
      LEFT JOIN students s ON s.program_id = p.program_id
      GROUP BY d.department_id, d.dept_code, d.dept_name
      HAVING COUNT(s.student_id) >= 1
      ORDER BY student_count DESC
    `);
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/reports/top-students', async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT * FROM vw_student_course_summary
      WHERE average_marks >= (SELECT AVG(average_marks) FROM vw_student_course_summary)
      ORDER BY average_marks DESC, roll_no
    `);
    res.json(rows.slice(0, 20));
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('*', (_req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`SIMS running at http://localhost:${PORT}`);
});
