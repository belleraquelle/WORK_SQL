SELECT * FROM all_students WHERE per_id = (SELECT per_id FROM all_students WHERE student_number = :student_number);

SELECT 
    student_awards.*,
    course_awards.awdt_code, 
    course_awards.cpst_code,
    award_classes.division,
    award_classes.title
FROM 
    student_awards 
    JOIN course_awards ON student_awards.cawd_id = course_awards.cawd_id
    JOIN award_classes ON student_awards.awcl_id = award_classes.awcl_id
WHERE 
    regn_id IN (SELECT regn_id FROM all_students WHERE per_id = (SELECT per_id FROM all_students WHERE student_number = :student_number));

SELECT 
    * 
FROM 
    student_unit_selections 
WHERE 
    regn_id IN (SELECT regn_id FROM all_students WHERE per_id = (SELECT per_id FROM all_students WHERE student_number = :student_number));
    
SELECT
    *
FROM
    course_positions
WHERE
    code = :course_position
;