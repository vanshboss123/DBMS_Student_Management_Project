-- ============================================================
-- DBMS LAB TOPIC DEMONSTRATION QUERIES
-- MySQL 8.0+ syntax; adapted from the supplied lab manual.
-- ============================================================
USE student_management;

-- 1. DDL: CREATE / ALTER / DROP / RENAME
CREATE TABLE ddl_demo (id INT PRIMARY KEY, note VARCHAR(50));
ALTER TABLE ddl_demo ADD COLUMN created_on DATE;
ALTER TABLE ddl_demo MODIFY COLUMN note VARCHAR(100);
ALTER TABLE ddl_demo RENAME COLUMN note TO description;
RENAME TABLE ddl_demo TO ddl_demo_renamed;
DROP TABLE ddl_demo_renamed;

-- 2. DML: INSERT / UPDATE / DELETE / TRUNCATE
INSERT INTO students (enrollment_no, first_name, last_name, email, gender, admission_year, dept_id)
VALUES ('DEMO001','Demo','Student','demo@example.com','Other',2026,1);
UPDATE students SET city='Nagpur' WHERE enrollment_no='DEMO001';
DELETE FROM students WHERE enrollment_no='DEMO001';
-- TRUNCATE is destructive; run only on a disposable table.

-- 3. NUMBER FUNCTIONS
SELECT ABS(-15) AS abs_val,
       POW(4,2) AS power_val,
       MOD(10,3) AS mod_val,
       ROUND(100.256,2) AS round_val,
       TRUNCATE(100.256,2) AS trunc_val,
       SQRT(16) AS sqrt_val;

-- 3. AGGREGATE FUNCTIONS
SELECT COUNT(*) AS total_students,
       SUM(salary) AS total_faculty_salary,
       AVG(salary) AS average_faculty_salary,
       MAX(salary) AS max_salary,
       MIN(salary) AS min_salary
FROM faculty;

-- 3. CHARACTER FUNCTIONS
SELECT UPPER(first_name), LOWER(email),
       CONCAT(first_name,' ',last_name) AS full_name,
       LENGTH(first_name) AS name_length,
       SUBSTRING(first_name,1,3) AS first_three,
       INSTR(email,'@') AS at_position,
       REPLACE(city,'a','A') AS replaced_city,
       LPAD(course_code,10,'*') AS lpad_code,
       RPAD(dept_code,8,'-') AS rpad_dept,
       LTRIM(CONCAT('  ',first_name)) AS ltrim_demo,
       RTRIM(CONCAT(last_name,'  ')) AS rtrim_demo
FROM students s JOIN departments d ON s.dept_id=d.dept_id;

-- 3. CONVERSION FUNCTIONS
SELECT CAST(1234.64 AS DECIMAL(10,2)) AS converted_number,
       CAST('2026-07-05' AS DATE) AS converted_date,
       DATE_FORMAT(CURDATE(),'%d-%m-%Y') AS formatted_date;

-- 3. DATE FUNCTIONS
SELECT CURDATE() AS today,
       DATE_ADD(CURDATE(), INTERVAL 2 MONTH) AS plus_two_months,
       LAST_DAY(CURDATE()) AS month_end,
       TIMESTAMPDIFF(YEAR,'2005-04-29',CURDATE()) AS age_years,
       DAYNAME(CURDATE()) AS weekday_name,
       GREATEST('2026-01-10','2026-12-01') AS greatest_date,
       LEAST('2026-01-10','2026-12-01') AS least_date;

-- 4. ARITHMETIC / LOGICAL / COMPARISON OPERATORS
SELECT course_code, credits, credits * 1000 AS credit_value,
       credits + 1 AS plus_one, credits - 1 AS minus_one,
       credits / 2 AS half_credits
FROM courses
WHERE credits >= 3 AND semester_no = 4;

-- 4. SPECIAL OPERATORS: BETWEEN, IS NULL, LIKE, IN, EXISTS, ANY, ALL
SELECT * FROM students WHERE admission_year BETWEEN 2024 AND 2026;
SELECT * FROM students WHERE phone IS NULL;
SELECT * FROM students WHERE first_name LIKE 'A%';
SELECT * FROM students WHERE dept_id IN (1,2);
SELECT * FROM students s WHERE EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id=s.student_id);
SELECT * FROM courses WHERE credits > ANY (SELECT credits FROM courses WHERE dept_id=1);
SELECT * FROM courses WHERE credits >= ALL (SELECT credits FROM courses WHERE dept_id=1);

-- 4. SET OPERATIONS
SELECT dept_id FROM students
UNION
SELECT dept_id FROM faculty;
SELECT dept_id FROM students
UNION ALL
SELECT dept_id FROM faculty;
-- MySQL 8.0.31+ supports INTERSECT / EXCEPT.
SELECT dept_id FROM students
INTERSECT
SELECT dept_id FROM faculty;
SELECT dept_id FROM students
EXCEPT
SELECT dept_id FROM faculty;

-- 5. JOINS: INNER JOIN
SELECT s.enrollment_no, CONCAT(s.first_name,' ',s.last_name) AS student_name, d.dept_name
FROM students s INNER JOIN departments d ON s.dept_id=d.dept_id;

-- 5. LEFT JOIN
SELECT d.dept_name, COUNT(s.student_id) AS student_count
FROM departments d LEFT JOIN students s ON s.dept_id=d.dept_id
GROUP BY d.dept_id, d.dept_name;

-- 5. RIGHT JOIN
SELECT d.dept_name, COUNT(s.student_id) AS student_count
FROM students s RIGHT JOIN departments d ON s.dept_id=d.dept_id
GROUP BY d.dept_id, d.dept_name;

-- 5. FULL OUTER JOIN emulation in MySQL
SELECT d.dept_id, d.dept_name, s.student_id
FROM departments d LEFT JOIN students s ON s.dept_id=d.dept_id
UNION
SELECT d.dept_id, d.dept_name, s.student_id
FROM departments d RIGHT JOIN students s ON s.dept_id=d.dept_id;

-- 5. NATURAL JOIN
SELECT dept_code, dept_name, location
FROM departments NATURAL JOIN (
    SELECT dept_id AS dept_id FROM students GROUP BY dept_id
) x;

-- 5. SELF JOIN
SELECT f1.faculty_name AS faculty_a, f2.faculty_name AS faculty_b, f1.dept_id
FROM faculty f1 JOIN faculty f2
  ON f1.dept_id=f2.dept_id AND f1.faculty_id < f2.faculty_id;

-- 5. NON-EQUI JOIN
SELECT f.faculty_name, c.course_code, f.salary, c.credits
FROM faculty f JOIN courses c ON f.salary / 20000 >= c.credits;

-- 6. GROUP BY / HAVING / ORDER BY
SELECT d.dept_name, COUNT(s.student_id) AS students
FROM departments d LEFT JOIN students s ON s.dept_id=d.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(s.student_id) >= 1
ORDER BY students DESC;

SELECT course_code, course_name, credits
FROM courses ORDER BY credits DESC, course_name ASC;

-- 6. INDEX inspection
SHOW INDEX FROM students;

-- 7. SUBQUERIES: scalar / IN / correlated / EXISTS
SELECT * FROM faculty
WHERE salary > (SELECT AVG(salary) FROM faculty);

SELECT * FROM students
WHERE dept_id IN (SELECT dept_id FROM departments WHERE location='Nagpur');

SELECT * FROM faculty f
WHERE salary > ANY (SELECT salary FROM faculty WHERE dept_id=f.dept_id AND faculty_id<>f.faculty_id);

SELECT * FROM students s
WHERE EXISTS (SELECT 1 FROM results r
              JOIN enrollments e ON e.enrollment_id=r.enrollment_id
              WHERE e.student_id=s.student_id AND r.marks >= 90);

-- 7. VIEW usage
SELECT * FROM v_student_department;
SELECT * FROM v_student_results ORDER BY marks DESC;

-- 8. CONSTRAINT validation examples
-- These statements should fail when uncommented:
-- INSERT INTO students(enrollment_no,first_name,last_name,email,gender,admission_year,dept_id)
-- VALUES ('IT2026001','Duplicate','Student','dup@example.com','Other',2026,1);
-- INSERT INTO results(enrollment_id,marks) VALUES(1,150);

-- 9. TCL: COMMIT / SAVEPOINT / ROLLBACK
START TRANSACTION;
UPDATE students SET city='Pune' WHERE student_id=1;
SAVEPOINT before_second_change;
UPDATE students SET city='Mumbai' WHERE student_id=2;
ROLLBACK TO SAVEPOINT before_second_change;
COMMIT;

-- 10. Stored procedure / MySQL equivalent to PL/SQL procedure
CALL sp_student_report(1);

-- 10. Stored function / MySQL equivalent to PL/SQL function
SELECT marks, fn_grade(marks) AS calculated_grade FROM results;

-- 12. Trigger verification
INSERT INTO students
(enrollment_no,first_name,last_name,email,gender,admission_year,dept_id)
VALUES ('TRG001','Trigger','Test','trigger.test@example.com','Other',2026,1);
SELECT * FROM student_audit_log ORDER BY log_id DESC LIMIT 5;
DELETE FROM students WHERE enrollment_no='TRG001';
SELECT * FROM student_audit_log ORDER BY log_id DESC LIMIT 5;

-- BACKUP/RECOVERY commands are documented in database/backup_restore.md.
