<?php
$pageTitle = $pageTitle ?? 'Student Information Management System';
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= htmlspecialchars($pageTitle) ?></title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<header class="topbar">
    <div class="brand">SIMS <span>DBMS Mini Project</span></div>
    <nav>
        <a href="index.php">Dashboard</a>
        <a href="students.php">Students</a>
        <a href="departments.php">Departments</a>
        <a href="courses.php">Courses</a>
        <a href="enrollments.php">Enrollments</a>
        <a href="results.php">Results</a>
    </nav>
</header>
<main class="container">
