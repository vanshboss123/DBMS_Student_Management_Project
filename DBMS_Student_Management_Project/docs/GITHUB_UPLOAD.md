# GitHub Upload Steps

This project is Git-ready, but a remote GitHub repository cannot be created from this environment without your GitHub authentication/connection.

## Create repository

Create a new empty GitHub repository named, for example:

`dbms-student-information-management-system`

Do not add another README if you are uploading this project as-is.

## Push the project

From the project root:

```bash
git init
git add .
git commit -m "Initial DBMS mini project"
git branch -M main
git remote add origin https://github.com/<your-username>/dbms-student-information-management-system.git
git push -u origin main
```

Then submit:

`https://github.com/<your-username>/dbms-student-information-management-system`

## Before pushing

- Keep `public/config.php` out of Git. It is already ignored in `.gitignore`.
- Use a strong MySQL password in your local configuration.
- Replace any personal/sample data if your college requires your own student details.
