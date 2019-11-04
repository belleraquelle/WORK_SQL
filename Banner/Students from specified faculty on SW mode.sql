/*

This report returns all students with a SW cohort code that hasn't been inactivated, who have a completion date in the future and are on
a programme attached to the specified faculty.

*/

SELECT DISTINCT
    spriden_id AS "Student_Number", 
    spriden_last_name AS "Last_Name",
    spriden_first_name AS "First_Name",
    sorlcur_program AS "Programme_Code", 
    sorlcur_term_code_admit AS "Admit_Term",
    sorlcur_end_date AS "Expected_Completion_Date",
    sorlcur_coll_code AS "Faculty",
    t1.sgrsatt_term_code_eff AS "Attribute_Term_Effective",
    t1.sgrsatt_atts_code AS "Current_Attribute"
FROM
    sorlcur
    JOIN sgrchrt ON sorlcur_pidm = sgrchrt_pidm AND sorlcur_key_seqno = sgrchrt_stsp_key_sequence
    JOIN spriden ON sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgrsatt t1 ON sorlcur_pidm = t1.sgrsatt_pidm AND sorlcur_key_seqno = t1.sgrsatt_stsp_key_sequence
WHERE
    1=1

    -- Return the latest curriculum record for programmes attached to specified college code
    AND sorlcur_coll_code = 'BU'
    AND sorlcur_lmod_code = 'LEARNER'
    AND sorlcur_term_code_end IS NULL

    -- Return curriculum records where the expected completion date is in the future=
    AND sorlcur_end_date > SYSDATE
    
    -- Only return study paths which have an SW cohort code
    AND sgrchrt_chrt_code = 'SW'
    
    -- Exclude students who have had the SW cohort code inactivated
    AND sorlcur_pidm NOT IN (
        SELECT sgrchrt_pidm
        FROM sgrchrt
        WHERE sgrchrt_chrt_code = 'SW' AND sgrchrt_active_ind = 'Y'
    )
    
    -- Restrict to only include current student attribute for the study path
    AND t1.sgrsatt_term_code_eff = (
        SELECT MAX(t2.sgrsatt_term_code_eff)
        FROM sgrsatt t2
        WHERE 
        1=1
        AND t2.sgrsatt_pidm = t1.sgrsatt_pidm 
        AND t2.sgrsatt_stsp_key_sequence = t1.sgrsatt_stsp_key_sequence
        AND t2.sgrsatt_term_code_eff <= '201909')
        
ORDER BY
    sorlcur_program,
    sorlcur_term_code_admit,
    spriden_last_name,
    spriden_first_name
;