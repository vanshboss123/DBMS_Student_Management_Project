const demoPrograms = [
  {program_id:1, program_name:'B.Tech Information Technology', program_code:'IT', dept_code:'IT', dept_name:'Information Technology'},
  {program_id:2, program_name:'B.Tech Computer Science', program_code:'CSE', dept_code:'CSE', dept_name:'Computer Science'},
  {program_id:3, program_name:'B.Tech Electronics & Telecommunication', program_code:'ENTC', dept_code:'ENTC', dept_name:'Electronics & Telecommunication'}
];
let demoStudents = [
  {student_id:1,roll_no:'IT2026-001',first_name:'Aarav',last_name:'Patil',email:'aarav@example.com',program_id:1,program_name:'B.Tech Information Technology',dept_code:'IT',status:'Active',city:'Nagpur'},
  {student_id:2,roll_no:'CSE2026-014',first_name:'Meera',last_name:'Kulkarni',email:'meera@example.com',program_id:2,program_name:'B.Tech Computer Science',dept_code:'CSE',status:'Active',city:'Nagpur'},
  {student_id:3,roll_no:'IT2026-025',first_name:'Rohan',last_name:'Joshi',email:'rohan@example.com',program_id:1,program_name:'B.Tech Information Technology',dept_code:'IT',status:'Active',city:'Wardha'},
  {student_id:4,roll_no:'ENTC2026-006',first_name:'Isha',last_name:'Deshmukh',email:'isha@example.com',program_id:3,program_name:'B.Tech Electronics & Telecommunication',dept_code:'ENTC',status:'Inactive',city:'Amravati'},
  {student_id:5,roll_no:'CSE2026-031',first_name:'Kabir',last_name:'Shah',email:'kabir@example.com',program_id:2,program_name:'B.Tech Computer Science',dept_code:'CSE',status:'Active',city:'Nagpur'}
];
const demoDepartments = [
  {dept_code:'IT',dept_name:'Information Technology',location:'Nagpur',student_count:12},
  {dept_code:'CSE',dept_name:'Computer Science',location:'Nagpur',student_count:9},
  {dept_code:'ENTC',dept_name:'Electronics & Telecommunication',location:'Nagpur',student_count:7},
  {dept_code:'ME',dept_name:'Mechanical Engineering',location:'Nagpur',student_count:5}
];
const demoCourses = [
  {course_code:'IT301',course_name:'Database Management Systems',credits:4,program_name:'B.Tech Information Technology',dept_code:'IT'},
  {course_code:'IT302',course_name:'Design and Analysis of Algorithms',credits:4,program_name:'B.Tech Information Technology',dept_code:'IT'},
  {course_code:'CSE305',course_name:'Operating Systems',credits:4,program_name:'B.Tech Computer Science',dept_code:'CSE'},
  {course_code:'ENTC310',course_name:'Microcontrollers',credits:3,program_name:'B.Tech Electronics & Telecommunication',dept_code:'ENTC'}
];

const state = {demo:false, view:'dashboard', programs:demoPrograms, students:demoStudents};
const $ = s => document.querySelector(s);
const $$ = s => [...document.querySelectorAll(s)];

function setMode(demo){
  state.demo = demo;
  const badge = $('#mode-badge');
  badge.textContent = demo ? 'DEMO DATA' : 'LIVE DATABASE';
  badge.classList.toggle('demo', demo);
}
function notice(msg){const n=$('#notice'); n.textContent=msg; n.classList.remove('hidden'); setTimeout(()=>n.classList.add('hidden'),5000)}
async function api(url, options={}){
  try{const r=await fetch(url,options); if(!r.ok) throw new Error(await r.text()); return await r.json();}
  catch(e){ state.demo=true; setMode(true); return null; }
}

function nav(view){
  state.view=view;
  $$('.nav-item').forEach(b=>b.classList.toggle('active',b.dataset.view===view));
  $$('.view').forEach(v=>v.classList.remove('active-view'));
  $(`#view-${view}`).classList.add('active-view');
  $('#page-title').textContent=view.charAt(0).toUpperCase()+view.slice(1);
  if(view==='dashboard') renderDashboard();
  if(view==='students') renderStudents();
  if(view==='departments') renderDepartments();
  if(view==='courses') renderCourses();
  if(view==='enrollments') renderEnrollments();
  if(view==='reports') renderReports();
}

async function getDashboard(){
  const data=await api('/api/dashboard');
  if(data) { setMode(false); return data; }
  return {totals:{students:demoStudents.length,departments:demoDepartments.length,programs:demoPrograms.length,courses:18,enrollments:46},recent:demoStudents.slice().reverse()};
}
async function renderDashboard(){
  const d=await getDashboard();
  const t=d.totals;
  $('#view-dashboard').innerHTML=`
    <div class="metric-grid">
      ${metric('Students',t.students)}${metric('Departments',t.departments)}${metric('Programs',t.programs)}${metric('Courses',t.courses)}${metric('Enrollments',t.enrollments)}
    </div>
    <div class="grid-2">
      <div class="panel"><div class="section-head"><h2>Recent Students</h2><span class="muted">Last 8 records</span></div>
        <div class="table-wrap"><table class="data-table"><thead><tr><th>Roll No</th><th>Name</th><th>Program</th><th>Status</th></tr></thead><tbody>
        ${(d.recent||[]).map(s=>`<tr><td><strong>${s.roll_no}</strong></td><td>${s.name||((s.first_name||'')+' '+(s.last_name||''))}</td><td>${s.program_name||'-'}</td><td><span class="tag">${s.status||'Active'}</span></td></tr>`).join('')}
        </tbody></table></div>
      </div>
      <div class="panel"><div class="section-head"><h2>DBMS Coverage</h2><span class="muted">Lab Manual</span></div>
        ${['DDL & DML','Functions & Operators','Joins','GROUP BY / HAVING / INDEX','Subqueries & Views','Constraints','Transactions','Users / Roles / DCL','Stored Programs & Triggers'].map(x=>`<div class="list-card"><span>${x}</span><span class="tag">Implemented</span></div>`).join('')}
      </div>
    </div>
    <div class="footer-note">Use the sidebar to inspect the relational data and reports. The website uses parameterized SQL in the Node/Express API.</div>`;
}
function metric(label,value){return `<div class="metric"><div class="label">${label}</div><div class="value">${value}</div></div>`}

async function renderStudents(){
  const live=await api('/api/students');
  if(live) state.students=live; else state.students=demoStudents;
  $('#view-students').innerHTML=`
    <div class="panel"><div class="section-head"><h2>Student Records</h2><button class="primary-btn" onclick="openStudent()">+ Add Student</button></div>
      <div class="search-row"><input id="student-search" placeholder="Search roll no, name or email"><select id="student-status"><option value="">All status</option><option>Active</option><option>Inactive</option><option>Graduated</option><option>Suspended</option></select><button class="secondary-btn" id="student-filter">Filter</button></div>
      <div id="student-table"></div>
    </div>`;
  renderStudentTable(state.students);
  $('#student-filter').onclick=async()=>{const s=$('#student-search').value.trim(), status=$('#student-status').value; let data=await api('/api/students?search='+encodeURIComponent(s)+'&status='+encodeURIComponent(status)); if(data)state.students=data; else state.students=demoStudents.filter(x=>(!s || (x.roll_no+x.first_name+x.last_name+x.email).toLowerCase().includes(s.toLowerCase())) && (!status||x.status===status)); renderStudentTable(state.students);};
}
function renderStudentTable(list){
  $('#student-table').innerHTML=`<div class="table-wrap"><table class="data-table"><thead><tr><th>Roll No</th><th>Student</th><th>Program</th><th>Department</th><th>Email</th><th>Status</th><th>Actions</th></tr></thead><tbody>${list.length?list.map(s=>`<tr><td><strong>${s.roll_no}</strong></td><td>${s.first_name} ${s.last_name}</td><td>${s.program_name||'-'}</td><td>${s.dept_code||'-'}</td><td>${s.email}</td><td><span class="tag">${s.status}</span></td><td><div class="row-actions"><button class="mini-btn" onclick='openStudent(${JSON.stringify(s)})'>Edit</button><button class="mini-btn delete" onclick="deleteStudent(${s.student_id})">Delete</button></div></td></tr>`).join(''):`<tr><td colspan="7"><div class="empty">No student records found.</div></td></tr>`}</tbody></table></div>`;
}

async function renderDepartments(){
  let data=await api('/api/departments'); if(!data)data=demoDepartments;
  $('#view-departments').innerHTML=`<div class="panel"><div class="section-head"><h2>Departments</h2><span class="muted">GROUP BY + LEFT JOIN</span></div><div class="two-col">${data.map(d=>`<div class="report-card"><h3>${d.dept_code} - ${d.dept_name}</h3><div class="stat-strip"><span class="stat-chip">${d.location||'Nagpur'}</span><span class="stat-chip">${d.student_count} students</span></div><div class="bar" style="margin-top:10px"><span style="width:${Math.min((Number(d.student_count)/15)*100,100)}%"></span></div></div>`).join('')}</div></div>`;
}
async function renderCourses(){
  let data=await api('/api/courses'); if(!data)data=demoCourses;
  $('#view-courses').innerHTML=`<div class="panel"><div class="section-head"><h2>Courses</h2><span class="muted">INNER JOIN course / program / department</span></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Code</th><th>Course</th><th>Credits</th><th>Program</th><th>Dept</th></tr></thead><tbody>${data.map(c=>`<tr><td><strong>${c.course_code}</strong></td><td>${c.course_name}</td><td>${c.credits}</td><td>${c.program_name}</td><td><span class="tag">${c.dept_code}</span></td></tr>`).join('')}</tbody></table></div></div>`;
}
async function renderEnrollments(){
  let data=await api('/api/enrollments');
  if(!data)data=demoStudents.map((s,i)=>({roll_no:s.roll_no,student_name:s.first_name+' '+s.last_name,course_code:['IT301','IT302','CSE305'][i%3],course_name:['DBMS','DAA','Operating Systems'][i%3],academic_year:'2026-27',semester:'IV',grade:['A','A+','B+'][i%3],status:'Enrolled'}));
  $('#view-enrollments').innerHTML=`<div class="panel"><div class="section-head"><h2>Enrollments</h2><span class="muted">Many-to-many relationship</span></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Roll No</th><th>Student</th><th>Course</th><th>Year</th><th>Semester</th><th>Grade</th><th>Status</th></tr></thead><tbody>${data.map(e=>`<tr><td>${e.roll_no}</td><td>${e.student_name}</td><td>${e.course_code} - ${e.course_name}</td><td>${e.academic_year}</td><td>${e.semester}</td><td>${e.grade||'-'}</td><td><span class="tag">${e.status}</span></td></tr>`).join('')}</tbody></table></div></div>`;
}
async function renderReports(){
  let dept=await api('/api/reports/department-strength'); if(!dept)dept=demoDepartments;
  let top=await api('/api/reports/top-students'); if(!top)top=demoStudents.map((s,i)=>({roll_no:s.roll_no,name:s.first_name+' '+s.last_name,average_marks:88-i*3}));
  $('#view-reports').innerHTML=`<div class="report-grid"><div class="panel"><div class="section-head"><h2>Department Strength</h2><span class="muted">GROUP BY / HAVING</span></div>${dept.map(d=>`<div class="list-card"><span>${d.dept_code} - ${d.dept_name}</span><strong>${d.student_count}</strong></div>`).join('')}</div><div class="panel"><div class="section-head"><h2>Above-Average Students</h2><span class="muted">View + subquery</span></div>${top.slice(0,8).map(x=>`<div class="list-card"><span>${x.roll_no} - ${x.name}</span><strong>${Number(x.average_marks).toFixed(1)}</strong></div>`).join('')}</div></div><div class="panel" style="margin-top:14px"><div class="section-head"><h2>Representative SQL</h2><span class="muted">MySQL</span></div><pre class="code">SELECT d.dept_code, COUNT(s.student_id) AS student_count\nFROM departments d\nLEFT JOIN programs p ON p.department_id=d.department_id\nLEFT JOIN students s ON s.program_id=p.program_id\nGROUP BY d.department_id, d.dept_code\nHAVING COUNT(s.student_id) &gt;= 1\nORDER BY student_count DESC;</pre></div>`;
}

async function populatePrograms(){
  let p=await api('/api/programs'); if(!p)p=demoPrograms; state.programs=p;
  $('#program_id').innerHTML=p.map(x=>`<option value="${x.program_id}">${x.program_name}</option>`).join('');
}
function openStudent(student=null){
  populatePrograms().then(()=>{
    const f=['student_id','roll_no','first_name','last_name','email','phone','dob','gender','admission_date','program_id','status','city','state','pin_code','address_line'];
    $('#student-form').reset(); $('#student_id').value=''; $('#dialog-title').textContent=student?'Edit Student':'Add Student';
    f.forEach(k=>{ if(student && document.getElementById(k)) document.getElementById(k).value = student[k] ?? ''; });
    $('#student-dialog').showModal();
  });
}
async function deleteStudent(id){
  if(!confirm('Delete this student record?'))return;
  if(state.demo){ demoStudents=demoStudents.filter(s=>s.student_id!==id); state.students=demoStudents; renderStudentTable(state.students); notice('Deleted in demo mode.'); return; }
  const r=await api('/api/students/'+id,{method:'DELETE'}); if(r&&r.message){notice('Student deleted.'); renderStudents();} else notice('Delete failed.');
}
$('#student-form').addEventListener('submit',async e=>{
  e.preventDefault();
  const ids=['roll_no','first_name','last_name','email','phone','dob','gender','admission_date','program_id','status','city','state','pin_code','address_line'];
  const data=Object.fromEntries(ids.map(id=>[id,$('#'+id).value||null]));
  const id=Number($('#student_id').value||0);
  if(state.demo){
    if(id){demoStudents=demoStudents.map(s=>s.student_id===id?{...s,...data,program_name:state.programs.find(p=>p.program_id==data.program_id)?.program_name||s.program_name,dept_code:state.programs.find(p=>p.program_id==data.program_id)?.dept_code||s.dept_code}:s)}
    else demoStudents.unshift({...data,student_id:Math.max(...demoStudents.map(s=>s.student_id))+1,program_name:state.programs.find(p=>p.program_id==data.program_id)?.program_name||'',dept_code:state.programs.find(p=>p.program_id==data.program_id)?.dept_code||''});
    $('#student-dialog').close(); renderStudents(); notice(id?'Updated in demo mode.':'Created in demo mode.'); return;
  }
  const r=await api(id?'/api/students/'+id:'/api/students',{method:id?'PUT':'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)});
  if(r&&r.student_id){$('#student-dialog').close(); renderStudents(); notice(id?'Student updated.':'Student created.');}
  else notice('Save failed. Check required fields and constraints.');
});
$('#new-student-btn').onclick=()=>openStudent(); $('#close-dialog').onclick=()=>$('#student-dialog').close(); $('#cancel-dialog').onclick=()=>$('#student-dialog').close();
$$('.nav-item').forEach(b=>b.onclick=()=>nav(b.dataset.view));

(async()=>{ const h=await api('/api/health'); setMode(!h); nav('dashboard'); })();
