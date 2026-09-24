-- Student Information Management System - master MySQL setup

-- ===== 00_create_database.sql =====
-- Experiment 1: DDL - database creation
DROP DATABASE IF EXISTS sims_db;
CREATE DATABASE sims_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sims_db;


-- ===== 01_schema.sql =====
USE sims_db;

-- Core normalized relational schema.
CREATE TABLE departments (
    department_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    dept_code VARCHAR(10) NOT NULL UNIQUE,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(80) NOT NULL DEFAULT 'Nagpur'
) ENGINE=InnoDB;

CREATE TABLE programs (
    program_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    department_id INT UNSIGNED NOT NULL,
    program_code VARCHAR(15) NOT NULL UNIQUE,
    program_name VARCHAR(120) NOT NULL UNIQUE,
    duration_years TINYINT UNSIGNED NOT NULL DEFAULT 4,
    CONSTRAINT chk_program_duration CHECK (duration_years BETWEEN 1 AND 6),
    CONSTRAINT fk_program_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE students (
    student_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    roll_no VARCHAR(25) NOT NULL UNIQUE,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(15) NULL UNIQUE,
    dob DATE NULL,
    gender ENUM('Male','Female','Other') NULL,
    admission_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    program_id INT UNSIGNED NOT NULL,
    status ENUM('Active','Inactive','Graduated','Suspended') NOT NULL DEFAULT 'Active',
    address_line VARCHAR(180) NULL,
    city VARCHAR(80) NOT NULL DEFAULT 'Nagpur',
    state VARCHAR(80) NOT NULL DEFAULT 'Maharashtra',
    pin_code CHAR(6) NULL,
    CONSTRAINT chk_pin_code CHECK (pin_code IS NULL OR pin_code REGEXP '^[0-9]{6}$'),
    CONSTRAINT fk_student_program FOREIGN KEY (program_id)
        REFERENCES programs(program_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE instructors (
    instructor_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_no VARCHAR(20) NOT NULL UNIQUE,
    instructor_name VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    department_id INT UNSIGNED NOT NULL,
    joined_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    salary DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT chk_instructor_salary CHECK (salary >= 0),
    CONSTRAINT fk_instructor_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE courses (
    course_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    program_id INT UNSIGNED NOT NULL,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(120) NOT NULL,
    credits DECIMAL(3,1) NOT NULL,
    CONSTRAINT chk_course_credits CHECK (credits > 0 AND credits <= 10),
    CONSTRAINT fk_course_program FOREIGN KEY (program_id)
        REFERENCES programs(program_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE course_offerings (
    offering_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_id INT UNSIGNED NOT NULL,
    instructor_id INT UNSIGNED NOT NULL,
    academic_year VARCHAR(9) NOT NULL,
    semester ENUM('I','II','III','IV','V','VI','VII','VIII') NOT NULL,
    room_no VARCHAR(20) NULL,
    CONSTRAINT uq_offering UNIQUE (course_id, academic_year, semester),
    CONSTRAINT fk_offering_course FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_offering_instructor FOREIGN KEY (instructor_id)
        REFERENCES instructors(instructor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE enrollments (
    enrollment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    offering_id INT UNSIGNED NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    marks DECIMAL(5,2) NULL,
    grade VARCHAR(2) NULL,
    status ENUM('Enrolled','Completed','Dropped') NOT NULL DEFAULT 'Enrolled',
    CONSTRAINT uq_enrollment UNIQUE (student_id, offering_id),
    CONSTRAINT chk_marks CHECK (marks IS NULL OR marks BETWEEN 0 AND 100),
    CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_enrollment_offering FOREIGN KEY (offering_id)
        REFERENCES course_offerings(offering_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE attendance (
    attendance_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT UNSIGNED NOT NULL,
    class_date DATE NOT NULL,
    present BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_attendance UNIQUE (enrollment_id, class_date),
    CONSTRAINT fk_attendance_enrollment FOREIGN KEY (enrollment_id)
        REFERENCES enrollments(enrollment_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE student_audit (
    audit_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NULL,
    action_type VARCHAR(20) NOT NULL,
    old_email VARCHAR(120) NULL,
    new_email VARCHAR(120) NULL,
    old_status VARCHAR(20) NULL,
    new_status VARCHAR(20) NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(128) NOT NULL DEFAULT 'system'
) ENGINE=InnoDB;

-- Indexing for frequent search/report columns (Experiment 6).
CREATE INDEX idx_students_name ON students(last_name, first_name);
CREATE INDEX idx_students_program ON students(program_id);
CREATE INDEX idx_enrollment_student ON enrollments(student_id);
CREATE INDEX idx_enrollment_offering ON enrollments(offering_id);
CREATE INDEX idx_instructors_department ON instructors(department_id);
CREATE INDEX idx_courses_program ON courses(program_id);


-- ===== 02_seed_data.sql =====
USE sims_db;

INSERT INTO departments (dept_code, dept_name, location) VALUES
('IT','Information Technology','Nagpur'),
('CSE','Computer Science','Nagpur'),
('ENTC','Electronics & Telecommunication','Nagpur'),
('ME','Mechanical Engineering','Nagpur');

INSERT INTO programs (department_id, program_code, program_name, duration_years) VALUES
(1,'IT','B.Tech Information Technology',4),
(2,'CSE','B.Tech Computer Science',4),
(3,'ENTC','B.Tech Electronics & Telecommunication',4),
(4,'ME','B.Tech Mechanical Engineering',4);

INSERT INTO instructors (employee_no, instructor_name, email, department_id, joined_date, salary) VALUES
('EMP001','Dr. Anil Verma','anil.verma@example.com',1,'2021-07-01',72000),
('EMP002','Dr. Neha Kulkarni','neha.kulkarni@example.com',2,'2020-08-17',78000),
('EMP003','Prof. Rakesh Patil','rakesh.patil@example.com',3,'2022-01-10',69000),
('EMP004','Prof. Priya Joshi','priya.joshi@example.com',4,'2019-06-20',66000);

INSERT INTO courses (program_id, course_code, course_name, credits) VALUES
(1,'IT301','Database Management Systems',4),
(1,'IT302','Design and Analysis of Algorithms',4),
(1,'IT303','Computer Networks',4),
(1,'IT304','Software Engineering',3),
(1,'IT305','Web Technology',3),
(2,'CSE301','Database Management Systems',4),
(2,'CSE302','Operating Systems',4),
(2,'CSE303','Computer Networks',4),
(3,'ENTC301','Microcontrollers',3),
(3,'ENTC302','Digital Communication',4),
(4,'ME301','Thermodynamics',4),
(4,'ME302','Manufacturing Processes',4);

INSERT INTO course_offerings (course_id, instructor_id, academic_year, semester, room_no) VALUES
(1,1,'2026-27','IV','IT-401'),
(2,1,'2026-27','IV','IT-402'),
(3,1,'2026-27','IV','IT-403'),
(4,1,'2026-27','IV','IT-404'),
(5,1,'2026-27','IV','IT-LAB'),
(6,2,'2026-27','IV','CSE-401'),
(7,2,'2026-27','IV','CSE-402'),
(8,2,'2026-27','IV','CSE-403'),
(9,3,'2026-27','IV','E-401'),
(10,3,'2026-27','IV','E-402'),
(11,4,'2026-27','IV','ME-401'),
(12,4,'2026-27','IV','ME-402');

INSERT INTO students (roll_no, first_name, last_name, email, phone, dob, gender, admission_date, program_id, status, address_line, city, state, pin_code) VALUES
('IT2026-001','Aarav','Patil','aarav.patil@example.com','9876500001','2006-03-14','Male','2026-07-10',1,'Active','Wardha Road','Nagpur','Maharashtra','440015'),
('IT2026-002','Sneha','Deshmukh','sneha.deshmukh@example.com','9876500002','2006-08-12','Female','2026-07-10',1,'Active','Manish Nagar','Nagpur','Maharashtra','440015'),
('IT2026-003','Yash','Shinde','yash.shinde@example.com','9876500003','2006-05-27','Male','2026-07-10',1,'Active','Trimurti Nagar','Nagpur','Maharashtra','440022'),
('CSE2026-014','Meera','Kulkarni','meera.kulkarni@example.com','9876500014','2006-01-21','Female','2026-07-10',2,'Active','Dharampeth','Nagpur','Maharashtra','440010'),
('CSE2026-015','Kabir','Shah','kabir.shah@example.com','9876500015','2006-11-03','Male','2026-07-10',2,'Active','Sadar','Nagpur','Maharashtra','440001'),
('CSE2026-016','Diya','Pande','diya.pande@example.com','9876500016','2006-09-09','Female','2026-07-10',2,'Inactive','Bajaj Nagar','Nagpur','Maharashtra','440010'),
('ENTC2026-006','Isha','Deshmukh','isha.deshmukh@example.com','9876500021','2006-04-18','Female','2026-07-10',3,'Active','Manewada','Nagpur','Maharashtra','440024'),
('ME2026-004','Om','Joshi','om.joshi@example.com','9876500031','2006-02-28','Male','2026-07-10',4,'Active','Wathoda','Nagpur','Maharashtra','440008');

INSERT INTO enrollments (student_id, offering_id, marks, grade, status) VALUES
(1,1,91,'A+','Completed'),
(1,2,88,'A','Completed'),
(1,3,84,'A','Completed'),
(2,1,86,'A','Completed'),
(2,2,81,'A','Completed'),
(2,3,79,'B+','Completed'),
(3,1,74,'B+','Completed'),
(4,6,92,'A+','Completed'),
(4,7,89,'A','Completed'),
(5,6,87,'A','Completed'),
(6,6,71,'B+','Completed'),
(7,9,90,'A+','Completed'),
(8,11,76,'B+','Completed');

INSERT INTO attendance (enrollment_id, class_date, present) VALUES
(1,'2026-08-01',1),(1,'2026-08-03',1),(1,'2026-08-05',0),
(2,'2026-08-01',1),(2,'2026-08-03',1),(2,'2026-08-05',1),
(4,'2026-08-01',1),(4,'2026-08-03',0),(4,'2026-08-05',1),
(8,'2026-08-01',1),(8,'2026-08-03',1);


-- ===== 04_views_procedures_triggers.sql =====
USE sims_db;

/* =========================================================
   EXPERIMENT 7: VIEWS
   ========================================================= */
DROP VIEW IF EXISTS vw_student_directory;
CREATE VIEW vw_student_directory AS
SELECT s.student_id, s.roll_no,
       CONCAT(s.first_name,' ',s.last_name) AS student_name,
       s.email, s.status, p.program_name, d.dept_code, d.dept_name
FROM students s
JOIN programs p ON p.program_id=s.program_id
JOIN departments d ON d.department_id=p.department_id;

DROP VIEW IF EXISTS vw_student_course_summary;
CREATE VIEW vw_student_course_summary AS
SELECT s.student_id, s.roll_no,
       CONCAT(s.first_name,' ',s.last_name) AS name,
       ROUND(AVG(e.marks),2) AS average_marks,
       COUNT(e.enrollment_id) AS courses_taken,
       SUM(CASE WHEN e.grade='A+' THEN 1 ELSE 0 END) AS aplus_count
FROM students s
LEFT JOIN enrollments e ON e.student_id=s.student_id
GROUP BY s.student_id,s.roll_no,s.first_name,s.last_name;

/* =========================================================
   EXPERIMENT 11: PL/SQL equivalent in MySQL
   The supplied manual names PL/SQL. MySQL uses stored procedures,
   functions, handlers and control-flow blocks instead of PL/SQL.
   ========================================================= */
DROP FUNCTION IF EXISTS fn_student_age;
DELIMITER $$
CREATE FUNCTION fn_student_age(p_dob DATE)
RETURNS INT
NOT DETERMINISTIC
NO SQL
BEGIN
  IF p_dob IS NULL THEN
    RETURN NULL;
  END IF;
  RETURN TIMESTAMPDIFF(YEAR, p_dob, CURRENT_DATE);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_get_student_report;
DELIMITER $$
CREATE PROCEDURE sp_get_student_report(IN p_student_id INT)
BEGIN
  DECLARE v_count INT DEFAULT 0;

  SELECT COUNT(*) INTO v_count
  FROM students
  WHERE student_id=p_student_id;

  IF v_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Student not found';
  ELSE
    SELECT * FROM vw_student_directory WHERE student_id=p_student_id;
    SELECT fn_student_age(dob) AS age_years FROM students WHERE student_id=p_student_id;
  END IF;
END$$
DELIMITER ;

-- Stored procedure call example:
-- CALL sp_get_student_report(1);

/* =========================================================
   EXPERIMENT 12: SQL TRIGGERS
   ========================================================= */
DROP TRIGGER IF EXISTS trg_students_before_insert;
DELIMITER $$
CREATE TRIGGER trg_students_before_insert
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
  SET NEW.email = LOWER(TRIM(NEW.email));
  SET NEW.first_name = TRIM(NEW.first_name);
  SET NEW.last_name = TRIM(NEW.last_name);
  IF NEW.pin_code IS NOT NULL AND NEW.pin_code NOT REGEXP '^[0-9]{6}$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='PIN code must contain exactly 6 digits';
  END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_students_after_insert;
DELIMITER $$
CREATE TRIGGER trg_students_after_insert
AFTER INSERT ON students
FOR EACH ROW
BEGIN
  INSERT INTO student_audit(student_id, action_type, new_email, new_status, changed_by)
  VALUES (NEW.student_id, 'INSERT', NEW.email, NEW.status, CURRENT_USER());
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_students_after_update;
DELIMITER $$
CREATE TRIGGER trg_students_after_update
AFTER UPDATE ON students
FOR EACH ROW
BEGIN
  IF NOT (OLD.email <=> NEW.email) OR NOT (OLD.status <=> NEW.status) THEN
    INSERT INTO student_audit(student_id, action_type, old_email, new_email, old_status, new_status, changed_by)
    VALUES (NEW.student_id, 'UPDATE', OLD.email, NEW.email, OLD.status, NEW.status, CURRENT_USER());
  END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_students_after_delete;
DELIMITER $$
CREATE TRIGGER trg_students_after_delete
AFTER DELETE ON students
FOR EACH ROW
BEGIN
  INSERT INTO student_audit(student_id, action_type, old_email, old_status, changed_by)
  VALUES (OLD.student_id, 'DELETE', OLD.email, OLD.status, CURRENT_USER());
END$$
DELIMITER ;

-- Demonstration queries:
-- SHOW TRIGGERS FROM sims_db;
-- SELECT * FROM student_audit ORDER BY audit_id DESC;

