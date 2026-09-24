# Schema Notes and Normalization

## Main relationships

- One `department` has many `programs`.
- One `program` has many `students`.
- One `program` has many `courses`.
- One `department` has many `instructors`.
- One `course` can have many semester `course_offerings`.
- One `instructor` can teach many `course_offerings`.
- `students` and `course_offerings` form a many-to-many relationship through `enrollments`.
- One `enrollment` can have many `attendance` rows.
- `student_audit` records trigger-generated data changes.

## Normalization rationale

**1NF:** Each column stores a single value and there are no repeating groups in the core relations.

**2NF:** The many-to-many relationship is separated into `enrollments`; non-key attributes depend on the whole enrollment key represented by the row identity plus unique student/offering pair.

**3NF:** Department details are kept in `departments`, program details in `programs`, course details in `courses`, and instructor details in `instructors`. Student rows reference a program rather than repeating department or program descriptive attributes. Enrollment rows reference offerings rather than repeating course and instructor descriptions.
