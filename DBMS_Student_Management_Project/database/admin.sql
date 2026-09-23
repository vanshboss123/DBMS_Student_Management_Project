-- MySQL 8.0+ DCL / user / role examples.
-- Run these statements as a privileged MySQL administrator.

CREATE USER IF NOT EXISTS 'sims_app'@'localhost' IDENTIFIED BY 'ChangeMe_StrongPassword!';
CREATE USER IF NOT EXISTS 'sims_readonly'@'localhost' IDENTIFIED BY 'ChangeMe_ReadOnly!';

GRANT SELECT, INSERT, UPDATE, DELETE ON student_management.* TO 'sims_app'@'localhost';
GRANT SELECT ON student_management.* TO 'sims_readonly'@'localhost';

CREATE ROLE IF NOT EXISTS 'sims_reporting';
GRANT SELECT ON student_management.v_student_results TO 'sims_reporting';
GRANT SELECT ON student_management.v_student_department TO 'sims_reporting';
GRANT 'sims_reporting' TO 'sims_readonly'@'localhost';

-- Revoke examples required by the lab manual:
-- REVOKE DELETE ON student_management.* FROM 'sims_app'@'localhost';
-- REVOKE 'sims_reporting' FROM 'sims_readonly'@'localhost';

-- Password change example:
-- ALTER USER 'sims_app'@'localhost' IDENTIFIED BY 'New_Strong_Password!';

-- Delete user example:
-- DROP USER IF EXISTS 'sims_readonly'@'localhost';
