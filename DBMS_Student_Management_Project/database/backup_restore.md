# MySQL Backup and Recovery

The supplied lab manual discusses database backup/recovery along with COMMIT, ROLLBACK and SAVEPOINT. For MySQL, use `mysqldump` for logical backup and the `mysql` client for restore.

## Backup

```bash
mysqldump -u root -p --single-transaction --routines --triggers student_management > student_management_backup.sql
```

## Restore

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS student_management;"
mysql -u root -p student_management < student_management_backup.sql
```

## Transaction controls

```sql
START TRANSACTION;
UPDATE students SET city = 'Pune' WHERE student_id = 1;
SAVEPOINT city_update;
UPDATE students SET city = 'Mumbai' WHERE student_id = 2;
ROLLBACK TO SAVEPOINT city_update;
COMMIT;
```

`COMMIT` makes the transaction changes permanent. `ROLLBACK` reverses uncommitted changes, and `ROLLBACK TO SAVEPOINT` reverses changes made after the chosen savepoint.
