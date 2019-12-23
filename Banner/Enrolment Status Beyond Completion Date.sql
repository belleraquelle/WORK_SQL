/*

Returns students with an 'Enrolled' status on a Study Path beyond their completion date.

*/

SELECT DISTINCT
    spriden_id AS "Student_ID", 
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    sorlcur_end_date AS "Completion_Date", 
    sorlcur_key_seqno AS "Study_Path",
    sorlcur_levl_code AS "Level",
    sorlcur_program AS "Course",
    stvterm_code AS "Term_Code",
    sfrensp_ests_code AS "Enrolment_Status"
FROM 
    sorlcur
    JOIN spriden ON sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sfrensp ON sorlcur_pidm = sfrensp_pidm AND sorlcur_key_seqno = sfrensp_key_seqno
    JOIN stvterm ON sfrensp_term_code = stvterm_code
WHERE
    1=1 
    AND sorlcur_lmod_code = 'LEARNER' 
    AND sorlcur_cact_code = 'ACTIVE' 
    AND sorlcur_current_cde = 'Y'
    AND sorlcur_term_code_end IS NULL
    AND sorlcur_end_date < stvterm_start_date 
    AND sfrensp_ests_code = 'EN'
ORDER BY
    sorlcur_levl_code,
    sorlcur_program,
    spriden_last_name || ', ' || spriden_first_name,
    stvterm_code ASC
;