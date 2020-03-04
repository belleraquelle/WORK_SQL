SELECT
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
    CASE
        WHEN shrapsp_astd_code_end_of_term = 'AF' THEN 'AF - Exclude for academic failure'
        WHEN shrapsp_astd_code_end_of_term = 'D2' THEN 'D2 - Decision deferred pending resolution of investigation for academic misconduct'
        WHEN shrapsp_astd_code_end_of_term = 'D3' THEN 'D3 - Decision deferred pending resit results'
        WHEN shrapsp_astd_code_end_of_term = 'G2' THEN 'G2 - Student does not qualify for their award yet, but is eligible to continue studying towards it'
        WHEN shrapsp_astd_code_end_of_term = 'G3' THEN 'G3 - Student does not qualify for their award, but is eligible to continue studying for a lower award'
        WHEN shrapsp_astd_code_end_of_term = 'P1' THEN 'P1 - Student can progress to the next stage of their programme'
        WHEN shrapsp_astd_code_end_of_term = 'P3' THEN 'P3 - Student cannot progress to the next of their programme, but is eligible to continue studying towards their current award aim'
    END AS "Progression_Decision",
    c1.shrapsp_prev_code AS "Additional_Decision_Code",
    CASE
        WHEN shrapsp_prev_code = 'C1' THEN 'C1 - Congratulations for achieving the highest possible classification on their award'
        WHEN shrapsp_prev_code = 'W1' THEN 'W1 - Student has failed too many modules to continue studying towards their current award'
        WHEN shrapsp_prev_code = 'W2' THEN 'W2 - Student is approaching the credit limit for their current award aim'
    END AS "Additional_Decision",
    szrcmnt_comment AS "SRCM Comment"
    
FROM
    sorlcur a1
    LEFT JOIN szrcmnt b1 ON a1.sorlcur_pidm = b1.szrcmnt_pidm AND a1.sorlcur_key_seqno = b1.szrcmnt_stsp_key_seqno
    LEFT JOIN shrapsp c1 ON a1.sorlcur_pidm = c1.shrapsp_pidm AND a1.sorlcur_key_seqno = c1.shrapsp_stsp_key_sequence
    JOIN sobcurr_add ON a1.sorlcur_curr_rule = sobcurr_curr_rule
    JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgrsatt s1 ON a1.sorlcur_pidm = sgrsatt_pidm AND a1.sorlcur_key_seqno = sgrsatt_stsp_key_sequence 
        AND s1.sgrsatt_term_code_eff = (SELECT MAX(s2.sgrsatt_term_code_eff) FROM sgrsatt s2 WHERE s1.sgrsatt_pidm = s2.sgrsatt_pidm AND s1.sgrsatt_stsp_key_sequence = s2.sgrsatt_stsp_key_sequence AND s2.sgrsatt_term_code_eff <= '201909')
    JOIN sgrstsp d1 ON a1.sorlcur_pidm = d1.sgrstsp_pidm AND a1.sorlcur_key_seqno = d1.sgrstsp_key_seqno
    
WHERE
    1=1
    -- Limit to students from exam committee population
    AND a1.sorlcur_pidm IN (SELECT GLBEXTR_KEY FROM GLBEXTR WHERE GLBEXTR_SELECTION = '202003_POSTGRADUATE')
    
    -- Limit to current Student Central comments
    AND ((b1.szrcmnt_group = '202003_POSTGRADUATE' AND b1.szrcmnt_type = 'SCENT') OR b1.szrcmnt_comment IS NULL)
    
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

    -- Only include decisions recorded after stipulated date
    AND (shrapsp_activity_date >= '20-FEB-2020' OR shrapsp_activity_date IS NULL)
    
    -- Limit to max sgrstsp term effective record and only return it if it is active
    AND d1.sgrstsp_term_code_eff = (
        SELECT MAX(d2.sgrstsp_term_code_eff)
        FROM sgrstsp d2
        WHERE d2.sgrstsp_pidm = d1.sgrstsp_pidm AND d2.sgrstsp_key_seqno = d1.sgrstsp_key_seqno)
    AND d1.sgrstsp_stsp_code = 'AS'
        
    AND NOT (c1.shrapsp_astd_code_end_of_term IS NULL AND c1.shrapsp_prev_code IS NULL AND b1.szrcmnt_comment IS NULL)
        
    ORDER BY
        "Faculty",
        "Faculty_Code",
        "Programme_of_Study",
        "Current_Stage"
    
;