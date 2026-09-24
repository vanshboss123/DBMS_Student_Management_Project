# Student Information Management System (SIMS)

A DBMS mini project built with **MySQL + Node.js/Express + HTML/CSS/JavaScript**. It is designed around the Student Information Management System idea and demonstrates the SQL concepts covered by the supplied DBMS Lab Manual.

## Features

- Student CRUD: Create, Read, Update and Delete.
- Department, program, course and enrollment relational model.
- Primary key, foreign key, unique, not null, check and default constraints.
- DDL and DML examples.
- Number, aggregate, character, conversion and date functions.
- Arithmetic, logical, comparison and special operators.
- Set operations: UNION, UNION ALL, INTERSECT and EXCEPT (MySQL 8.0.31+).
- Inner, left, right, natural, self, cross and non-equi joins.
- GROUP BY, HAVING, ORDER BY and indexing.
- Subqueries including IN, ANY, ALL and correlated queries.
- Views.
- Stored procedures and stored functions as the MySQL equivalent of the manual's PL/SQL section.
- SQL triggers for validation and audit logging.
- Transactions with COMMIT, ROLLBACK and SAVEPOINT.
- Backup and recovery commands using `mysqldump`.
- MySQL users, roles, GRANT and REVOKE examples.
- Responsive browser interface.

## Project Structure

```text
student_information_management_system/
├── public/
│   ├── index.html
│   ├── styles.css
│   └── app.js
├── sql/
│   ├── 00_create_database.sql
│   ├── 01_schema.sql
│   ├── 02_seed_data.sql
│   ├── 03_queries.sql
│   ├── 04_views_procedures_triggers.sql
│   ├── 05_transactions.sql
│   ├── 06_admin_dcl.sql
│   └── 07_backup_recovery.md
├── docs/
│   ├── er_diagram.svg
│   ├── schema_notes.md
│   └── screenshots/
├── reports/
│   └── DBMS_Mini_Project_Report.pdf
├── server.js
├── package.json
├── .env.example
└── README.md
```

## Requirements

- MySQL 8.0.31+ recommended. MySQL 8.4 LTS is also suitable.
- Node.js 18+.
- npm.
- A browser such as Chrome/Edge/Firefox.

## Setup

### 1. Create the database

Open MySQL Workbench or the MySQL CLI and run:

```sql
SOURCE sql/00_create_database.sql;
SOURCE sql/01_schema.sql;
SOURCE sql/02_seed_data.sql;
SOURCE sql/04_views_procedures_triggers.sql;

Or run the one-file setup: `sql/sims_db_setup.sql`.
```

The query collection in `sql/03_queries.sql` is for demonstration and lab practice. `sql/05_transactions.sql` contains transaction examples. `sql/06_admin_dcl.sql` contains optional administrative commands.

### 2. Configure the Node application

```bash
cp .env.example .env
```

Edit `.env` with the MySQL username and password.

### 3. Install packages

```bash
npm install
```

### 4. Start the website

```bash
npm start
```

Open `http://localhost:3000`.

## API Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/dashboard` | Dashboard totals and recent students |
| GET | `/api/students` | List/search students |
| POST | `/api/students` | Create a student |
| PUT | `/api/students/:id` | Update a student |
| DELETE | `/api/students/:id` | Delete a student |
| GET | `/api/departments` | Departments with student counts |
| GET | `/api/courses` | Course list |
| GET | `/api/enrollments` | Enrollment list |
| GET | `/api/reports/department-strength` | GROUP BY/HAVING demonstration |
| GET | `/api/reports/top-students` | Subquery/view-backed report |

## Database Design

The core tables are:

- `departments`: academic departments.
- `programs`: programs offered by departments.
- `students`: student master data.
- `instructors`: instructors linked to departments.
- `courses`: course master data.
- `course_offerings`: semester-specific course offerings.
- `enrollments`: student-to-course-offering relationship.
- `attendance`: attendance records for enrollments.
- `student_audit`: trigger-generated audit records.

The design separates repeating and dependent data to keep the model close to 3NF. See `docs/schema_notes.md` for the mapping of the attributes and relationships.

## MySQL vs Oracle Note

The supplied manual mixes Oracle-specific syntax and terminology, including `NUMBER`, `VARCHAR2`, `DUAL`, Oracle-style outer joins and PL/SQL. This project is required to use MySQL, so those concepts are translated to MySQL-compatible forms. The source manual explicitly lists a PL/SQL experiment and an SQL Trigger experiment but does not provide detailed pages for both at the end of the supplied 46-page file; this project therefore implements the corresponding MySQL stored-program and trigger features separately.

## Backup and Recovery

Backup:

```bash
mysqldump -u root -p --routines --triggers --single-transaction sims_db > sims_backup.sql
```

Restore into an existing database:

```bash
mysql -u root -p sims_db < sims_backup.sql
```

See `sql/07_backup_recovery.md`.

## GitHub Submission

1. Create a new public/private GitHub repository, for example `student-information-management-system-dbms`.
2. Copy the project folder into the repository.
3. Commit and push:

```bash
git init
git add .
git commit -m "DBMS mini project - Student Information Management System"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/student-information-management-system-dbms.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username. Do not commit `.env` or real database passwords.

## Suggested Viva Demonstration Order

1. Show the ER diagram and explain PK/FK relationships.
2. Run `00_create_database.sql`, `01_schema.sql` and `02_seed_data.sql`.
3. Demonstrate a student create/update/delete from the website.
4. Show joins, functions, GROUP BY/HAVING, indexing and subqueries from `03_queries.sql`.
5. Show the view, procedure, function and trigger definitions.
6. Run the transaction examples and demonstrate SAVEPOINT/ROLLBACK/COMMIT.
7. Explain the backup command and the optional role/GRANT/REVOKE commands.
