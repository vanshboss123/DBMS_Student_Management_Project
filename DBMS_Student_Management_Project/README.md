# Student Information Management System - DBMS Mini Project

A MySQL-based Student Information Management System created as a DBMS laboratory mini project. The project maps the supplied DBMS lab manual topics to one relational application instead of isolated SQL exercises.

## Main Features

- Student, department, course, enrollment and result management.
- CRUD operations using a PHP web interface and prepared statements.
- Primary key, foreign key, unique, not-null, check and default constraints.
- Normalized relational design with bridge tables for many-to-many relationships.
- SQL demonstrations for DDL, DML, functions, operators, joins, GROUP BY/HAVING, ORDER BY and indexing.
- Subqueries, views, transactions, stored procedure, stored function and triggers.
- MySQL DCL examples: users, roles, GRANT and REVOKE.
- Backup/recovery commands using `mysqldump` and `mysql` restore.

## Technology Stack

- MySQL 8.0+
- PHP 8+
- HTML5 / CSS3
- InnoDB

## Folder Structure

```text
DBMS_Student_Management_Project/
├── database/
│   ├── student_management.sql
│   ├── queries.sql
│   ├── admin.sql
│   ├── backup_restore.md
│   └── README.md
├── public/
│   ├── index.php
│   ├── students.php
│   ├── departments.php
│   ├── courses.php
│   ├── enrollments.php
│   ├── results.php
│   ├── db.php
│   ├── config.example.php
│   ├── partials/
│   └── assets/
├── docs/
├── screenshots/
├── report/
└── README.md
```

## Setup

1. Install MySQL 8.0+ and PHP 8+ with the PDO MySQL extension. XAMPP can be used on Windows.
2. Open MySQL and run `database/student_management.sql`.
3. Copy `public/config.example.php` to `public/config.php` and set the MySQL username/password.
4. Start the PHP application from the `public` directory:

```bash
cd public
php -S localhost:8000
```

5. Open `http://localhost:8000`.

## Database Scripts

Run `database/queries.sql` after the schema is loaded to demonstrate individual DBMS topics. `database/admin.sql` contains privileged user/role examples. See `database/backup_restore.md` for backup and recovery commands.

## Important MySQL Adaptation Note

The supplied manual is Oracle-oriented in several places and includes PL/SQL, tablespace syntax and Oracle-style examples. This project uses MySQL as requested. Therefore, PL/SQL examples are represented with MySQL stored procedures/functions, Oracle tablespace commands are replaced with MySQL-compatible administration, and full outer join is demonstrated through LEFT JOIN + RIGHT JOIN with UNION because MySQL does not provide a `FULL OUTER JOIN` clause.

## Suggested GitHub Repository Description

> MySQL + PHP DBMS mini project covering DDL, DML, SQL functions, operators, joins, constraints, GROUP BY/HAVING, indexing, subqueries, views, transactions, stored routines, triggers and DCL through a Student Information Management System.

## Screenshots

See the `screenshots/` folder and `report/DBMS_Mini_Project_Report.pdf`.
