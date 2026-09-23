-- ============================================================
-- DBMS MINI PROJECT: Student Information Management System
-- Target DBMS: MySQL 8.0+
-- ============================================================

CREATE DATABASE IF NOT EXISTS student_management
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_management;

SET FOREIGN_KEY_CHECKS = 0;
DROP VIEW IF EXISTS v_student_results;
DROP VIEW IF EXISTS v_student_department;
DROP TRIGGER IF EXISTS trg_students_after_insert;
DROP TRIGGER IF EXISTS trg_students_after_update;
DROP TRIGGER IF EXISTS trg_students_after_delete;
DROP TRIGGER IF EXISTS trg_results_before_insert;
DROP TRIGGER IF EXISTS trg_results_before_update;
DROP PROCEDURE IF EXISTS sp_student_report;
DROP FUNCTION IF EXISTS fn_grade;
DROP TABLE IF EXISTS student_audit_log;
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS course_faculty;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS faculty;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS departments;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_code VARCHAR(10) NOT NULL UNIQUE,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL DEFAULT 'Nagpur',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_no VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE,
    dob DATE,
    gender ENUM('Male','Female','Other') NOT NULL,
    city VARCHAR(80) NOT NULL DEFAULT 'Nagpur',
    admission_year YEAR NOT NULL,
    dept_id INT NOT NULL,
    status ENUM('Active','Graduated','Inactive') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_student_admission_year CHECK (admission_year BETWEEN 2000 AND 2100),
    CONSTRAINT fk_student_department FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    designation VARCHAR(60) NOT NULL,
    dept_id INT NOT NULL,
    joined_on DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL CHECK (salary > 0),
    CONSTRAINT fk_faculty_department FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(15) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    credits TINYINT NOT NULL CHECK (credits BETWEEN 1 AND 8),
    dept_id INT NOT NULL,
    semester_no TINYINT NOT NULL CHECK (semester_no BETWEEN 1 AND 8),
    CONSTRAINT fk_course_department FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester_no TINYINT NOT NULL CHECK (semester_no BETWEEN 1 AND 8),
    academic_year VARCHAR(9) NOT NULL,
    enrolled_on DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT uq_student_course_term UNIQUE (student_id, course_id, semester_no, academic_year),
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_enroll_course FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE course_faculty (
    course_id INT NOT NULL,
    faculty_id INT NOT NULL,
    assigned_on DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (course_id, faculty_id),
    CONSTRAINT fk_cf_course FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_cf_faculty FOREIGN KEY (faculty_id)
        REFERENCES faculty(faculty_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE,
    marks DECIMAL(5,2) NOT NULL CHECK (marks BETWEEN 0 AND 100),
    grade CHAR(2) NOT NULL DEFAULT 'F',
    result_status ENUM('Pass','Fail') NOT NULL DEFAULT 'Fail',
    remarks VARCHAR(200),
    evaluated_on DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_result_enrollment FOREIGN KEY (enrollment_id)
        REFERENCES enrollments(enrollment_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE student_audit_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NULL,
    action_type ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    old_email VARCHAR(120) NULL,
    new_email VARCHAR(120) NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Indexes (Experiment 6)
CREATE INDEX idx_students_department ON students(dept_id);
CREATE INDEX idx_students_city ON students(city);
CREATE INDEX idx_courses_department_semester ON courses(dept_id, semester_no);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
CREATE INDEX idx_results_marks ON results(marks);

-- Sample data
INSERT INTO departments (dept_code, dept_name, location) VALUES
('IT','Information Technology','Nagpur'),
('CSE','Computer Science Engineering','Nagpur'),
('ECE','Electronics & Communication','Nagpur'),
('MECH','Mechanical Engineering','Nagpur'),
('CIVIL','Civil Engineering','Nagpur');

INSERT INTO students
(enrollment_no, first_name, last_name, email, phone, dob, gender, city, admission_year, dept_id, status) VALUES
('IT2026001','Aarav','Patil','aarav.patil@example.com','9876500011','2006-06-14','Male','Nagpur',2026,1,'Active'),
('IT2026002','Riya','Sharma','riya.sharma@example.com','9876500012','2006-02-18','Female','Wardha',2026,1,'Active'),
('CSE2026001','Kabir','Joshi','kabir.joshi@example.com','9876500013','2005-11-03','Male','Nagpur',2026,2,'Active'),
('CSE2025007','Ananya','Kulkarni','ananya.k@example.com','9876500014','2005-08-25','Female','Amravati',2025,2,'Active'),
('ECE2025004','Vihaan','More','vihaan.more@example.com','9876500015','2005-12-08','Male','Bhandara',2025,3,'Active'),
('IT2024009','Meera','Deshpande','meera.d@example.com','9876500016','2005-04-29','Female','Nagpur',2024,1,'Graduated'),
('ME2025003','Aditya','Gawande','aditya.g@example.com','9876500017','2005-09-11','Male','Akola',2025,4,'Active'),
('CIVIL2025006','Ishita','Raut','ishita.raut@example.com','9876500018','2006-01-19','Female','Nagpur',2025,5,'Active');

INSERT INTO faculty (faculty_name, email, designation, dept_id, joined_on, salary) VALUES
('Dr. Nilesh Kulkarni','nilesh.k@example.com','Professor',1,'2018-07-01',98000),
('Prof. Sneha Jadhav','sneha.j@example.com','Assistant Professor',1,'2020-08-10',76000),
('Dr. Rahul Borkar','rahul.b@example.com','Professor',2,'2016-06-15',105000),
('Prof. Pooja Kale','pooja.k@example.com','Assistant Professor',3,'2021-07-20',72000),
('Prof. Manish Wankhede','manish.w@example.com','Associate Professor',4,'2017-01-09',88000),
('Dr. Kavita Tiwari','kavita.t@example.com','Professor',5,'2015-07-13',102000);

INSERT INTO courses (course_code, course_name, credits, dept_id, semester_no) VALUES
('IT401','Database Management Systems',4,1,4),
('IT402','Data Structures',4,1,4),
('IT403','Web Technologies',3,1,4),
('CSE301','Operating Systems',4,2,3),
('CSE302','Computer Networks',4,2,3),
('ECE305','Digital Electronics',4,3,3),
('MECH303','Engineering Thermodynamics',4,4,3),
('CIVIL304','Structural Analysis',4,5,3);

INSERT INTO course_faculty (course_id, faculty_id) VALUES
(1,1),(2,2),(3,2),(4,3),(5,3),(6,4),(7,5),(8,6);

INSERT INTO enrollments (student_id, course_id, semester_no, academic_year, enrolled_on) VALUES
(1,1,4,'2026-27','2026-07-05'),
(1,2,4,'2026-27','2026-07-05'),
(1,3,4,'2026-27','2026-07-05'),
(2,1,4,'2026-27','2026-07-05'),
(2,2,4,'2026-27','2026-07-05'),
(3,4,3,'2026-27','2026-07-06'),
(3,5,3,'2026-27','2026-07-06'),
(4,4,3,'2026-27','2026-07-06'),
(4,5,3,'2026-27','2026-07-06'),
(5,6,3,'2026-27','2026-07-06'),
(6,1,4,'2025-26','2025-07-10'),
(6,3,4,'2025-26','2025-07-10'),
(7,7,3,'2026-27','2026-07-07'),
(8,8,3,'2026-27','2026-07-07');

INSERT INTO results (enrollment_id, marks, remarks) VALUES
(1,88,'Strong DBMS concepts'),
(2,81,'Good problem solving'),
(3,76,'Good project work'),
(4,91,'Excellent'),
(5,72,'Needs more practice'),
(6,84,'Good OS fundamentals'),
(7,79,'Good networking basics'),
(8,68,'Satisfactory'),
(9,73,'Good'),
(10,87,'Strong digital logic'),
(11,95,'Outstanding'),
(12,89,'Very good'),
(13,64,'Satisfactory'),
(14,58,'Needs improvement');

-- Views (Experiment 7)
CREATE OR REPLACE VIEW v_student_department AS
SELECT s.student_id, s.enrollment_no,
       CONCAT(s.first_name,' ',s.last_name) AS student_name,
       d.dept_code, d.dept_name, s.city, s.status
FROM students s
JOIN departments d ON d.dept_id = s.dept_id;

CREATE OR REPLACE VIEW v_student_results AS
SELECT s.student_id, s.enrollment_no,
       CONCAT(s.first_name,' ',s.last_name) AS student_name,
       c.course_code, c.course_name,
       e.semester_no, e.academic_year,
       r.marks, r.grade, r.result_status
FROM students s
JOIN enrollments e ON e.student_id = s.student_id
JOIN courses c ON c.course_id = e.course_id
JOIN results r ON r.enrollment_id = e.enrollment_id;

-- Stored function: MySQL equivalent to a PL/SQL function
DELIMITER $$
CREATE FUNCTION fn_grade(p_marks DECIMAL(5,2))
RETURNS CHAR(2)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN p_marks >= 90 THEN 'A+'
        WHEN p_marks >= 80 THEN 'A'
        WHEN p_marks >= 70 THEN 'B'
        WHEN p_marks >= 60 THEN 'C'
        WHEN p_marks >= 50 THEN 'D'
        ELSE 'F'
    END;
END$$

CREATE PROCEDURE sp_student_report(IN p_student_id INT)
BEGIN
    SELECT *
    FROM v_student_results
    WHERE student_id = p_student_id
    ORDER BY semester_no, course_code;
END$$
DELIMITER ;

-- Triggers (Experiment 12)
DELIMITER $$
CREATE TRIGGER trg_results_before_insert
BEFORE INSERT ON results
FOR EACH ROW
BEGIN
    SET NEW.grade = fn_grade(NEW.marks);
    SET NEW.result_status = IF(NEW.marks >= 50,'Pass','Fail');
END$$

CREATE TRIGGER trg_results_before_update
BEFORE UPDATE ON results
FOR EACH ROW
BEGIN
    SET NEW.grade = fn_grade(NEW.marks);
    SET NEW.result_status = IF(NEW.marks >= 50,'Pass','Fail');
END$$

CREATE TRIGGER trg_students_after_insert
AFTER INSERT ON students
FOR EACH ROW
BEGIN
    INSERT INTO student_audit_log(student_id, action_type, new_email)
    VALUES(NEW.student_id,'INSERT',NEW.email);
END$$

CREATE TRIGGER trg_students_after_update
AFTER UPDATE ON students
FOR EACH ROW
BEGIN
    INSERT INTO student_audit_log(student_id, action_type, old_email, new_email)
    VALUES(NEW.student_id,'UPDATE',OLD.email,NEW.email);
END$$

CREATE TRIGGER trg_students_after_delete
AFTER DELETE ON students
FOR EACH ROW
BEGIN
    INSERT INTO student_audit_log(student_id, action_type, old_email)
    VALUES(OLD.student_id,'DELETE',OLD.email);
END$$
DELIMITER ;

COMMIT;

-- End of schema
