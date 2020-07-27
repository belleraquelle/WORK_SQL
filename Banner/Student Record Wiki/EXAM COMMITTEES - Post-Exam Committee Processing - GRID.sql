SELECT DISTINCT
    a1.sorlcur_coll_code AS "Faculty_Code",
    CASE
        WHEN a1.sorlcur_coll_code IN ('BH','BL','BT','HH','HT','LT') THEN '# Cross Faculty Joint Programme'
        WHEN a1.sorlcur_coll_code = 'BU' THEN 'Oxford Brookes Business School'
        WHEN a1.sorlcur_coll_code = 'HL' THEN 'Faculty of Health and Life Sciences'
        WHEN a1.sorlcur_coll_code = 'HS' THEN 'Faculty of Humanities and Social Sciences'
        WHEN a1.sorlcur_coll_code = 'TD' THEN 'Faculty of Technology, Design and Environment'
    END AS "Faculty",
	a1.sorlcur_pidm AS "Student_PIDM",
    spriden_id AS "Student_ID",
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    a1.sorlcur_program AS "Programme_of_Study",
    s1.sgrsatt_atts_code AS "Current_Stage",
    --s1.sgrsatt_term_code_eff,
    c1.shrapsp_term_code,
    c1.shrapsp_astd_code_end_of_term AS "Progression_Decision_Code",
    c1.shrapsp_prev_code AS "Additional_Decision_Code",
    b1.szrcmnt_comment AS "Latest_SRCM_Comment",
    e1.szrcmnt_comment AS "Latest_ExCom_Comment"
    
FROM
    sorlcur a1
    LEFT JOIN szrcmnt b1 ON a1.sorlcur_pidm = b1.szrcmnt_pidm AND a1.sorlcur_key_seqno = b1.szrcmnt_stsp_key_seqno
    	AND b1.szrcmnt_group = :popsel_name AND b1.szrcmnt_type = 'SCENT' AND b1.szrcmnt_date = 
    		(SELECT MAX(b2.szrcmnt_date) FROM szrcmnt b2 WHERE b1.szrcmnt_pidm = b2.szrcmnt_pidm AND b2.szrcmnt_group = :popsel_name AND b2.szrcmnt_type = 'SCENT')
    LEFT JOIN szrcmnt e1 ON a1.sorlcur_pidm = e1.szrcmnt_pidm AND a1.sorlcur_key_seqno = e1.szrcmnt_stsp_key_seqno
    	AND e1.szrcmnt_group = :popsel_name AND e1.szrcmnt_type = 'EXCOM' AND e1.szrcmnt_date = 
    		(SELECT MAX(e2.szrcmnt_date) FROM szrcmnt e2 WHERE e1.szrcmnt_pidm = e2.szrcmnt_pidm AND e2.szrcmnt_group = :popsel_name AND e2.szrcmnt_type = 'EXCOM')
    LEFT JOIN shrapsp c1 ON a1.sorlcur_pidm = c1.shrapsp_pidm AND a1.sorlcur_key_seqno = c1.shrapsp_stsp_key_sequence AND shrapsp_term_code = :decision_term_code
    JOIN sobcurr_add ON a1.sorlcur_curr_rule = sobcurr_curr_rule
    JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgrsatt s1 ON a1.sorlcur_pidm = sgrsatt_pidm AND a1.sorlcur_key_seqno = sgrsatt_stsp_key_sequence 
        AND s1.sgrsatt_term_code_eff = (SELECT MAX(s2.sgrsatt_term_code_eff) FROM sgrsatt s2 WHERE s1.sgrsatt_pidm = s2.sgrsatt_pidm AND s1.sgrsatt_stsp_key_sequence = s2.sgrsatt_stsp_key_sequence AND s2.sgrsatt_term_code_eff <= :decision_term_code)
    JOIN sgrstsp d1 ON a1.sorlcur_pidm = d1.sgrstsp_pidm AND a1.sorlcur_key_seqno = d1.sgrstsp_key_seqno
    
WHERE
    1=1
    -- Limit to students from exam committee population
    AND a1.sorlcur_pidm IN (SELECT GLBEXTR_KEY FROM GLBEXTR WHERE GLBEXTR_SELECTION = :popsel_name)
    
    -- Limit to max sorlcur learner record
    AND a1.sorlcur_term_code = (
        SELECT MAX(a2.sorlcur_term_code)
        FROM sorlcur a2
        WHERE a2.sorlcur_pidm = a1.sorlcur_pidm AND a2.sorlcur_key_seqno = a1.sorlcur_key_seqno AND a2.sorlcur_lmod_code = 'LEARNER')
    AND a1.sorlcur_current_cde = 'Y'
    AND a1.sorlcur_cact_code = 'ACTIVE'
    AND a1.sorlcur_lmod_code = 'LEARNER'
    
    -- Limit to max SHRAPSP record
    AND (c1.shrapsp_term_code = (
        SELECT MAX(c2.shrapsp_term_code) 
        FROM shrapsp c2 
        WHERE c1.shrapsp_pidm = c2.shrapsp_pidm AND c1.shrapsp_stsp_key_sequence = c2.shrapsp_stsp_key_sequence AND (c2.shrapsp_astd_code_end_of_term IS NOT NULL OR c2.shrapsp_prev_code IS NOT NULL)
        )
        OR c1.shrapsp_term_code IS NULL)

    -- Only include decisions recorded against specified term
    --AND (shrapsp_term_code = :decision_term_code OR shrapsp_term_code IS NULL)
    
    -- Limit to max sgrstsp term effective record and only return it if it is active
    AND d1.sgrstsp_term_code_eff = (
        SELECT MAX(d2.sgrstsp_term_code_eff)
        FROM sgrstsp d2
        WHERE d2.sgrstsp_pidm = d1.sgrstsp_pidm AND d2.sgrstsp_key_seqno = d1.sgrstsp_key_seqno)
    AND d1.sgrstsp_stsp_code = 'AS'
        
    AND NOT (c1.shrapsp_astd_code_end_of_term IS NULL AND c1.shrapsp_prev_code IS NULL AND b1.szrcmnt_comment IS NULL AND e1.szrcmnt_comment IS NULL)
    
    --AND a1.sorlcur_pidm = '1255910'
    --AND spriden_id = '19044377'
        
    ORDER BY
        "Faculty",
        "Faculty_Code",
        "Programme_of_Study",
        "Current_Stage"
    
;