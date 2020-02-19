SELECT
    sornote_pidm AS "Person_ID", 
    spriden_id AS "Student_Number", 
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    sgrstsp_key_seqno AS "Study_Path",
    sgrstsp_stsp_code AS "Study_Path_Status",
    sornote_creation_date AS "Comment_Date",
    sornote_note AS "Comment",
    sornote_user_id AS "Comment_User", 
    sornote_activity_date AS "Comment_Update_Date",
    sorlcur_term_code AS "Curriculum_Term_Code",
    sorlcur_program AS "Course",
    sorlcur_key_seqno AS "Course_Study_Path",
    sorlcur_end_date AS "Expected_Completion_Date"
    
FROM 
    sornote
    JOIN sgbstdn a1 ON sornote_student_pidm = a1.sgbstdn_pidm
    JOIN sorlcur b1 ON sornote_student_pidm = b1.sorlcur_pidm AND b1.sorlcur_lmod_code = 'LEARNER'
    JOIN spriden c1 ON sornote_student_pidm = c1.spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgrstsp d1 ON sornote_student_pidm = d1.sgrstsp_pidm AND sorlcur_key_seqno = sgrstsp_key_seqno
    
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
    
    AND d1.sgrstsp_term_code_eff = (
        SELECT MAX(d2.sgrstsp_term_code_eff)
        FROM sgrstsp d2
        WHERE d1.sgrstsp_pidm = d2.sgrstsp_pidm AND d1.sgrstsp_key_seqno = d2.sgrstsp_key_seqno
    )
    
    AND a1.sgbstdn_stst_code = 'AS'
    AND d1.sgrstsp_stsp_code = 'AS'
    AND sornote_note LIKE 'Cr%'
    
    AND b1.sorlcur_pidm || b1.sorlcur_key_seqno NOT IN (
        SELECT shrdgmr_pidm || shrdgmr_stsp_key_sequence
        FROM shrdgmr
        WHERE shrdgmr_degs_code = 'AW'
    )
    
ORDER BY
    sorlcur_program
;