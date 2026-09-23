<?php
require __DIR__ . '/db.php';
$pageTitle = 'Dashboard';
$counts = [
  'students' => $pdo->query('SELECT COUNT(*) FROM students')->fetchColumn(),
  'departments' => $pdo->query('SELECT COUNT(*) FROM departments')->fetchColumn(),
  'courses' => $pdo->query('SELECT COUNT(*) FROM courses')->fetchColumn(),
  'enrollments' => $pdo->query('SELECT COUNT(*) FROM enrollments')->fetchColumn(),
];
$recent = $pdo->query('SELECT * FROM v_student_results ORDER BY student_id DESC, course_code LIMIT 8')->fetchAll();
include __DIR__ . '/partials/header.php';
?>
<div class="hero"><div><h1>Student Information Management System</h1><p>Database-driven CRUD dashboard demonstrating DBMS laboratory concepts.</p></div><a class="btn" href="students.php">Manage Students</a></div>
<div class="grid">
  <?php foreach ($counts as $label => $count): ?><div class="card"><div class="label"><?= ucfirst($label) ?></div><div class="metric"><?= (int)$count ?></div></div><?php endforeach; ?>
</div>
<div class="section"><h2>Recent Result Records</h2><div class="table-wrap"><table class="table"><tr><th>Student</th><th>Course</th><th>Semester</th><th>Marks</th><th>Grade</th><th>Status</th></tr><?php foreach($recent as $r): ?><tr><td><?= htmlspecialchars($r['student_name']) ?></td><td><?= htmlspecialchars($r['course_code']) ?></td><td><?= $r['semester_no'] ?></td><td><?= $r['marks'] ?></td><td><?= htmlspecialchars($r['grade']) ?></td><td><span class="pill <?= $r['result_status']==='Pass'?'pass':'fail' ?>"><?= htmlspecialchars($r['result_status']) ?></span></td></tr><?php endforeach; ?></table></div></div>
<div class="section grid"><div class="card"><strong>SQL Topics</strong><p class="label">DDL, DML, functions, operators, joins, GROUP BY/HAVING, ORDER BY, indexes.</p></div><div class="card"><strong>Advanced</strong><p class="label">Subqueries, views, stored procedure/function, triggers, transactions and DCL examples.</p></div><div class="card"><strong>Normalization</strong><p class="label">Core transactional tables are designed around 1NF, 2NF and 3NF principles.</p></div><div class="card"><strong>MySQL</strong><p class="label">InnoDB, foreign keys, constraints, prepared statements and MySQL 8 syntax.</p></div></div>
<?php include __DIR__ . '/partials/footer.php'; ?>
