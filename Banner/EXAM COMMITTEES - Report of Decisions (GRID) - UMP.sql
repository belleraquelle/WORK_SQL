SELECT DISTINCT
    sorlcur_coll_code AS "Faculty_Code",
    CASE
        WHEN sorlcur_coll_code IN ('BH','BL','BT','HH','HT','LT') THEN '# Cross Faculty Joint Programme'
        WHEN sorlcur_coll_code = 'BU' THEN 'Oxford Brookes Business School'
        WHEN sorlcur_coll_code = 'HL' THEN 'Faculty of Health and Life Sciences'
        WHEN sorlcur_coll_code = 'HS' THEN 'Faculty of Humanities and Social Sciences'
        WHEN sorlcur_coll_code = 'TD' THEN 'Faculty of Technology, Design and Environment'
    END AS "Faculty",
	shrapsp_pidm AS "Student_PIDM",
    spriden_id AS "Student_ID",
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    t1.sorlcur_program AS "Programme_of_Study",
    s1.sgrsatt_atts_code AS "Current_Stage",
    CASE
        WHEN shrapsp_pidm IN (SELECT GLBEXTR_KEY FROM GLBEXTR WHERE GLBEXTR_SELECTION = '202001_GOLD') THEN '3. Gold'
        WHEN shrapsp_pidm IN (SELECT GLBEXTR_KEY FROM GLBEXTR WHERE GLBEXTR_SELECTION = '202001_SILVER') THEN '2. Grey'
        WHEN shrapsp_pidm IN (SELECT GLBEXTR_KEY FROM GLBEXTR WHERE GLBEXTR_SELECTION = '202001_PINK') THEN '1. Pink'
    END AS "Exam_Book",
    --s1.sgrsatt_term_code_eff,
    --shrapsp_astd_code_end_of_term,
    CASE
        WHEN shrapsp_astd_code_end_of_term = 'AF' THEN 'AF - Exclude for academic failure'
        WHEN shrapsp_astd_code_end_of_term = 'D2' THEN 'D2 - Decision deferred pending resolution of investigation for academic misconduct'
        WHEN shrapsp_astd_code_end_of_term = 'D3' THEN 'D3 - Decision deferred pending resit results'
        WHEN shrapsp_astd_code_end_of_term = 'G2' THEN 'G2 - Student does not qualify for their award yet, but is eligible to continue studying towards is'  
        WHEN shrapsp_astd_code_end_of_term = 'P1' THEN 'P1 - Student can progress to the next stage of their programme'
        WHEN shrapsp_astd_code_end_of_term = 'P3' THEN 'P3 - Student cannot progress to the next of their programme, but is eligible to continue studying towards their current award aim'
    END AS "Progression_Decision",
    --shrapsp_prev_code,
    CASE
        WHEN shrapsp_prev_code = 'C1' THEN 'C1 - Congratulations for achieving the highest possible classification on their award'
        WHEN shrapsp_prev_code = 'W1' THEN 'W1 - Student has failed too many modules to continue studying towards their current award'
    END AS "Additional_Decision"
FROM
	shrapsp
	JOIN sorlcur t1 ON shrapsp_stsp_key_sequence = t1.sorlcur_key_seqno AND shrapsp_pidm = sorlcur_pidm
	JOIN sobcurr_add ON t1.sorlcur_curr_rule = sobcurr_curr_rule
    JOIN spriden ON shrapsp_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgrsatt s1 ON t1.sorlcur_pidm = sgrsatt_pidm AND t1.sorlcur_key_seqno = sgrsatt_stsp_key_sequence 
        AND s1.sgrsatt_term_code_eff = (SELECT MAX(s2.sgrsatt_term_code_eff) FROM sgrsatt s2 WHERE s1.sgrsatt_pidm = s2.sgrsatt_pidm AND s1.sgrsatt_stsp_key_sequence = s2.sgrsatt_stsp_key_sequence AND s2.sgrsatt_term_code_eff <= '201909')
WHERE
    1=1
	--AND shrapsp_astd_code_end_of_term = 'G3'
	AND shrapsp_term_code = '201909'
	AND shrapsp_activity_date >= '01-JAN-2020'
    --AND shrapsp_pidm NOT IN (SELECT gorvisa_pidm FROM gorvisa WHERE gorvisa_vtyp_code = 'T4')
	AND (ump_1 IS NOT NULL OR sorlcur_program IN ('CHEU','DHEU'))
    
    AND t1.sorlcur_term_code = (
        SELECT MAX(t2.sorlcur_term_code)
        FROM sorlcur t2
        WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER')
    AND t1.sorlcur_current_cde = 'Y'
    AND t1.sorlcur_cact_code = 'ACTIVE'
    AND t1.sorlcur_lmod_code = 'LEARNER'

ORDER BY
    "Faculty",
    "Faculty_Code",
    "Programme_of_Study",
    "Exam_Book",
    "Current_Stage",
    "Progression_Decision",
    "Additional_Decision"
;