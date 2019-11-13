/*

This query returns all students on specified program(s) who have an expected completion date in the future,
and lists their current adviser.

*/


SELECT
    s1.spriden_id AS "Student_Number",
    s1.spriden_last_name || ', ' || s1.spriden_first_name AS "Student_Name",
    sorlcur_term_code_admit AS "Admit_Term",
    sorlcur_program AS "Programme",
    sorlcur_end_date AS "Expected_Completion_Date",
    sorlcur_camp_code AS "Campus_Code",
    t1.sgradvr_advr_code AS "Advisor_Code",
    s2.spriden_last_name || ', ' || s2.spriden_first_name AS "Adviser_Name"

FROM
    sorlcur
    JOIN spriden s1 ON sorlcur_pidm = s1.spriden_pidm AND s1.spriden_change_ind IS NULL
    LEFT JOIN sgradvr t1 ON sorlcur_pidm = t1.sgradvr_pidm
    LEFT JOIN spriden s2 ON sgradvr_advr_pidm = s2.spriden_pidm AND s2.spriden_change_ind IS NULL

WHERE
    1=1
    
    -- Curriculum criteria
    AND sorlcur_lmod_code = 'LEARNER'
    AND sorlcur_term_code_end IS NULL
    AND sorlcur_end_date > sysdate
    AND (sorlcur_program IN ('BSCH-PX') OR sorlcur_program LIKE '%PX%') -- Enter programme codes here!

    -- Max Advisor Record
    AND (t1.sgradvr_term_code_eff = (
            SELECT MAX(t2.sgradvr_term_code_eff)
            FROM sgradvr t2
            WHERE t2.sgradvr_pidm = t1.sgradvr_pidm)
        OR t1.sgradvr_advr_code IS NULL)
        
    
ORDER BY
    s2.spriden_last_name || ', ' || s2.spriden_first_name,
    s1.spriden_last_name || ', ' || s1.spriden_first_name
;