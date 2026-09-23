<?php
require __DIR__ . '/db.php';
$pageTitle='Students';
$message=''; $edit=null;
if ($_SERVER['REQUEST_METHOD']==='POST') {
    $action=$_POST['action'] ?? '';
    try {
        if($action==='create'){
            $st=$pdo->prepare('INSERT INTO students(enrollment_no,first_name,last_name,email,phone,dob,gender,city,admission_year,dept_id,status) VALUES(?,?,?,?,?,?,?,?,?,?,?)');
            $st->execute([$_POST['enrollment_no'],$_POST['first_name'],$_POST['last_name'],$_POST['email'],$_POST['phone']?:null,$_POST['dob']?:null,$_POST['gender'],$_POST['city'],$_POST['admission_year'],$_POST['dept_id'],$_POST['status']]);
            $message='Student created successfully.';
        } elseif($action==='update'){
            $st=$pdo->prepare('UPDATE students SET enrollment_no=?,first_name=?,last_name=?,email=?,phone=?,dob=?,gender=?,city=?,admission_year=?,dept_id=?,status=? WHERE student_id=?');
            $st->execute([$_POST['enrollment_no'],$_POST['first_name'],$_POST['last_name'],$_POST['email'],$_POST['phone']?:null,$_POST['dob']?:null,$_POST['gender'],$_POST['city'],$_POST['admission_year'],$_POST['dept_id'],$_POST['status'],$_POST['student_id']]);
            $message='Student updated successfully.';
        } elseif($action==='delete'){
            $st=$pdo->prepare('DELETE FROM students WHERE student_id=?'); $st->execute([$_POST['student_id']]); $message='Student deleted.';
        }
    } catch(Throwable $e){$message='Error: '.$e->getMessage();}
}
if(isset($_GET['edit'])) { $st=$pdo->prepare('SELECT * FROM students WHERE student_id=?');$st->execute([$_GET['edit']]);$edit=$st->fetch(); }
$depts=$pdo->query('SELECT dept_id,dept_name FROM departments ORDER BY dept_name')->fetchAll();
$students=$pdo->query('SELECT s.*,d.dept_name FROM students s JOIN departments d ON d.dept_id=s.dept_id ORDER BY s.student_id DESC')->fetchAll();
include __DIR__.'/partials/header.php';
?>
<div class="hero"><div><h1>Student Management</h1><p>CRUD operations with constraints, prepared statements and foreign keys.</p></div><a class="btn light" href="students.php">Clear Form</a></div>
<?php if($message): ?><div class="notice <?= str_starts_with($message,'Error')?'error':'success' ?>"><?= htmlspecialchars($message) ?></div><?php endif; ?>
<div class="form-card"><h2><?= $edit?'Edit Student':'Add Student' ?></h2><form method="post"><input type="hidden" name="action" value="<?= $edit?'update':'create' ?>"><?php if($edit): ?><input type="hidden" name="student_id" value="<?= $edit['student_id'] ?>"><?php endif; ?><div class="form-grid">
<?php $v=fn($k)=>htmlspecialchars($edit[$k]??''); ?>
<div class="field"><label>Enrollment No.</label><input name="enrollment_no" required value="<?=$v('enrollment_no')?>"></div><div class="field"><label>First Name</label><input name="first_name" required value="<?=$v('first_name')?>"></div><div class="field"><label>Last Name</label><input name="last_name" required value="<?=$v('last_name')?>"></div>
<div class="field"><label>Email</label><input type="email" name="email" required value="<?=$v('email')?>"></div><div class="field"><label>Phone</label><input name="phone" value="<?=$v('phone')?>"></div><div class="field"><label>Date of Birth</label><input type="date" name="dob" value="<?=$v('dob')?>"></div>
<div class="field"><label>Gender</label><select name="gender"><?php foreach(['Male','Female','Other'] as $x): ?><option <?=$edit&&$edit['gender']===$x?'selected':''?>><?=$x?></option><?php endforeach; ?></select></div><div class="field"><label>City</label><input name="city" value="<?=$v('city')?:'Nagpur'?>"></div><div class="field"><label>Admission Year</label><input type="number" name="admission_year" min="2000" max="2100" required value="<?=$v('admission_year')?:date('Y')?>"></div>
<div class="field"><label>Department</label><select name="dept_id" required><?php foreach($depts as $d): ?><option value="<?=$d['dept_id']?>" <?=$edit&&$edit['dept_id']==$d['dept_id']?'selected':''?>><?=htmlspecialchars($d['dept_name'])?></option><?php endforeach; ?></select></div><div class="field"><label>Status</label><select name="status"><?php foreach(['Active','Graduated','Inactive'] as $x): ?><option <?=$edit&&$edit['status']===$x?'selected':''?>><?=$x?></option><?php endforeach; ?></select></div><div class="field"><button class="btn" type="submit"><?= $edit?'Update Student':'Create Student' ?></button></div></div></form></div>
<div class="section"><h2>Student Records</h2><div class="table-wrap"><table class="table"><tr><th>ID</th><th>Enrollment</th><th>Name</th><th>Email</th><th>Department</th><th>City</th><th>Status</th><th>Actions</th></tr><?php foreach($students as $s): ?><tr><td><?=$s['student_id']?></td><td><?=htmlspecialchars($s['enrollment_no'])?></td><td><?=htmlspecialchars($s['first_name'].' '.$s['last_name'])?></td><td><?=htmlspecialchars($s['email'])?></td><td><?=htmlspecialchars($s['dept_name'])?></td><td><?=htmlspecialchars($s['city'])?></td><td><?=htmlspecialchars($s['status'])?></td><td class="actions"><a class="btn small secondary" href="?edit=<?=$s['student_id']?>">Edit</a><form method="post" onsubmit="return confirm('Delete this student?')"><input type="hidden" name="action" value="delete"><input type="hidden" name="student_id" value="<?=$s['student_id']?>"><button class="btn small danger">Delete</button></form></td></tr><?php endforeach; ?></table></div></div>
<?php include __DIR__.'/partials/footer.php'; ?>
