SELECT
	sr.brookes_student_number,
	sr.surname,
	sr.forenames,
	s.stage_title,
	qc.class_title
	--ssa.*
FROM
	student_registrations sr 
	JOIN student_stage_awards ssa ON sr.brookes_student_number = ssa.brookes_student_number
	JOIN stages s ON ssa.brookes_stage_code = s.brookes_stage_code
	JOIN qual_classifications qc ON ssa.ssa_qcl_id = qc.qcl_id
	
WHERE 
	sr.brookes_student_number = '21086789'
;


SELECT * FROM stage_mark_elements WHERE brookes_student_number = '21086789';


SELECT * FROM mark_element_details;
SELECT * FROM courses;
SELECT * FROM stages;
SELECT * FROM student_registrations;
SELECT * FROM qual_classifications;