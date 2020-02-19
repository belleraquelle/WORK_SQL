/*

Students on UTWD for the specified Term

*/

SELECT DISTINCT
    spriden_id AS "Student_Number", 
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name", 
    s1.sfrensp_pidm AS "Person_ID",
    s1.sfrensp_key_seqno AS "Enrolment_Study_Path",
    s1.sfrensp_term_code AS "Enrolment_Term_Code",
    s1.sfrensp_ests_code AS "Study_Path_Enrolment_Status",
    a1.sorlcur_program AS "Programme",
    a1.sorlcur_key_seqno AS "Programme_Study_Path",
    b1.sgrstsp_stsp_code AS "Study_Path_Status",
    a1.sorlcur_end_date AS "Expected_Completion_Date"
FROM
    sfrensp s1
    --JOIN sgbstdn t1 ON s1.sfrensp_pidm = t1.sgbstdn_pidm
    JOIN spriden ON s1.sfrensp_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sorlcur a1 ON sfrensp_pidm = a1.sorlcur_pidm AND sfrensp_key_seqno = a1.sorlcur_key_seqno
    JOIN sgrstsp b1 ON s1.sfrensp_pidm = b1.sgrstsp_pidm AND s1.sfrensp_key_seqno = b1.sgrstsp_key_seqno
WHERE
    1=1
    AND s1.sfrensp_ests_code IN ('UT') 
    AND s1.sfrensp_term_code = '202001'
    AND a1.sorlcur_term_code = (
        SELECT MAX(a2.sorlcur_term_code) 
        FROM sorlcur a2 
        WHERE a1.sorlcur_pidm = a2.sorlcur_pidm AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno AND a1.sorlcur_lmod_code = 'LEARNER'
        )
    AND b1.sgrstsp_term_code_eff = (
        SELECT MAX(b2.sgrstsp_term_code_eff) 
        FROM sgrstsp b2 
        WHERE b1.sgrstsp_pidm = b2.sgrstsp_pidm AND b1.sgrstsp_key_seqno = b2.sgrstsp_key_seqno
        )
    AND a1.sorlcur_end_date > '01-JAN-2020'
ORDER BY
    a1.sorlcur_program
;