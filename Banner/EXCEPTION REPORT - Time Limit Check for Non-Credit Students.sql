SELECT
    spriden_pidm AS "Person_ID", 
    spriden_id AS "Student_Number", 
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    sgrstsp_key_seqno AS "Study_Path",
    sgrstsp_stsp_code AS "Study_Path_Status",
    sorlcur_term_code AS "Curriculum_Term_Code",
    sorlcur_program AS "Course",
    sorlcur_levl_code AS "Course_Level",
    sorlcur_key_seqno AS "Course_Study_Path",
    sorlcur_start_date AS "Study_Path_Start_Date",
    sorlcur_end_date AS "Expected_Completion_Date"
    
FROM 
    sgbstdn a1
    JOIN sorlcur b1 ON a1.sgbstdn_pidm = b1.sorlcur_pidm AND b1.sorlcur_lmod_code = 'LEARNER'
    JOIN spriden c1 ON a1.sgbstdn_pidm = c1.spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgrstsp d1 ON a1.sgbstdn_pidm = d1.sgrstsp_pidm AND b1.sorlcur_key_seqno = d1.sgrstsp_key_seqno
    
WHERE
    1=1
    
    AND a1.sgbstdn_term_code_eff = (
        SELECT MAX(a2.sgbstdn_term_code_eff) FROM sgbstdn a2 WHERE a1.sgbstdn_pidm = a2.sgbstdn_pidm
    )
    
    AND b1.sorlcur_term_code = (
        SELECT MAX(b2.sorlcur_term_code) 
        FROM sorlcur b2 
        WHERE b1.sorlcur_pidm = b2.sorlcur_pidm AND b1.sorlcur_key_seqno = b2.sorlcur_key_seqno AND b1.sorlcur_lmod_code = 'LEARNER'
        )
        
    AND sorlcur_term_code_end IS NULL
    AND sorlcur_end_date > sysdate
    AND sorlcur_start_date <= '31-AUG-14'
    AND sorlcur_levl_code IN ('FD','UG','PG')
    AND sorlcur_camp_code IN ('OBO','OBS','DL')
    
    AND d1.sgrstsp_term_code_eff = (
        SELECT MAX(d2.sgrstsp_term_code_eff)
        FROM sgrstsp d2
        WHERE d1.sgrstsp_pidm = d2.sgrstsp_pidm AND d1.sgrstsp_key_seqno = d2.sgrstsp_key_seqno
    )
    
    AND a1.sgbstdn_stst_code = 'AS'
    AND d1.sgrstsp_stsp_code = 'AS'
    
    AND b1.sorlcur_pidm || b1.sorlcur_key_seqno NOT IN (
        SELECT shrdgmr_pidm || shrdgmr_stsp_key_sequence
        FROM shrdgmr
        WHERE shrdgmr_degs_code = 'AW'
    )
    
ORDER BY
    sorlcur_program
;