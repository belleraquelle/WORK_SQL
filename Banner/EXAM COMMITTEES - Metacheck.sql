/*

METACHECK! Outputs a host of Exam Committee related data for final checking.

*/


SELECT DISTINCT
    sorlcur_coll_code AS "Faculty_Code",
    CASE
        WHEN sorlcur_coll_code IN ('BH','BL','BT','HH','HT','LT') THEN '# Cross Faculty Joint Programme'
        WHEN sorlcur_coll_code = 'BU' THEN 'Oxford Brookes Business School'
        WHEN sorlcur_coll_code = 'HL' THEN 'Faculty of Health and Life Sciences'
        WHEN sorlcur_coll_code = 'HS' THEN 'Faculty of Humanities and Social Sciences'
        WHEN sorlcur_coll_code = 'TD' THEN 'Faculty of Technology, Design and Environment'
    END AS "Faculty",
	t1.sorlcur_pidm AS "Student_PIDM",
    spriden_id AS "Student_ID",
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    t1.sorlcur_program AS "Programme_of_Study",
    s1.sgrsatt_atts_code AS "Current_Stage",
    t1.sorlcur_end_date AS "Expected_Completion_Date",
    CASE
        WHEN t1.sorlcur_pidm IN (SELECT GLBEXTR_KEY FROM GLBEXTR WHERE GLBEXTR_SELECTION = '202001_GOLD') THEN '3. Gold'
        WHEN t1.sorlcur_pidm IN (SELECT GLBEXTR_KEY FROM GLBEXTR WHERE GLBEXTR_SELECTION = '202001_SILVER') THEN '2. Grey'
        WHEN t1.sorlcur_pidm IN (SELECT GLBEXTR_KEY FROM GLBEXTR WHERE GLBEXTR_SELECTION = '202001_PINK') THEN '1. Pink'
    END AS "Exam_Book",
    --s1.sgrsatt_term_code_eff,
    shrapsp_astd_code_end_of_term AS "Exam_Committee_Decision",
--    CASE
--        WHEN shrapsp_astd_code_end_of_term = 'AF' THEN 'AF - Exclude for academic failure'
--        WHEN shrapsp_astd_code_end_of_term = 'D2' THEN 'D2 - Decision deferred pending resolution of investigation for academic misconduct'
--        WHEN shrapsp_astd_code_end_of_term = 'D3' THEN 'D3 - Decision deferred pending resit results'
--        WHEN shrapsp_astd_code_end_of_term = 'G2' THEN 'G2 - Student does not qualify for their award yet, but is eligible to continue studying towards is'  
--        WHEN shrapsp_astd_code_end_of_term = 'P1' THEN 'P1 - Student can progress to the next stage of their programme'
--        WHEN shrapsp_astd_code_end_of_term = 'P3' THEN 'P3 - Student cannot progress to the next of their programme, but is eligible to continue studying towards their current award aim'
--    END AS "Progression_Decision",
    shrapsp_prev_code AS "Additional_Decision",
--    CASE
--        WHEN shrapsp_prev_code = 'C1' THEN 'C1 - Congratulations for achieving the highest possible classification on their award'
--        WHEN shrapsp_prev_code = 'W1' THEN 'W1 - Student has failed too many modules to continue studying towards their current award'
--    END AS "Additional_Decision",
    shrdgmr_degc_code AS "Award",
    shrdgmr_majr_code_1 AS "Major",
    shrdgmr_degs_code AS "Award_Status",
    shrdgih_honr_code AS "Classification",
    shrdgcm_comment AS "Average",
    shrdgcm_data_origin AS "Average_Source", 
    
    CASE
        WHEN shrapsp_pidm IN (SELECT shrmrks_pidm FROM shrmrks WHERE shrmrks_comments = 'Exceptional Circumstances') THEN 'Y'
    END AS "ExCircs Comment",
    CASE
        WHEN shrapsp_pidm IN (
            SELECT t1.shrtckg_pidm 
            FROM shrtckg t1 
            WHERE t1.shrtckg_seq_no = (SELECT MAX(t2.shrtckg_seq_no) FROM shrtckg t2 WHERE t2.shrtckg_pidm = t1.shrtckg_pidm AND t2.shrtckg_term_code = t1.shrtckg_term_code AND t2.shrtckg_tckn_seq_no = t1.shrtckg_tckn_seq_no) 
            AND shrtckg_grde_code_final = 'DD') THEN 'Y'
    END AS "DD Grade"
FROM
	sorlcur t1
	LEFT JOIN shrapsp ON shrapsp_stsp_key_sequence = t1.sorlcur_key_seqno AND shrapsp_pidm = sorlcur_pidm
	JOIN sobcurr_add ON t1.sorlcur_curr_rule = sobcurr_curr_rule
    JOIN spriden ON sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgrsatt s1 ON t1.sorlcur_pidm = sgrsatt_pidm AND t1.sorlcur_key_seqno = sgrsatt_stsp_key_sequence 
        AND s1.sgrsatt_term_code_eff = (SELECT MAX(s2.sgrsatt_term_code_eff) FROM sgrsatt s2 WHERE s1.sgrsatt_pidm = s2.sgrsatt_pidm AND s1.sgrsatt_stsp_key_sequence = s2.sgrsatt_stsp_key_sequence AND s2.sgrsatt_term_code_eff <= '201909')
    LEFT JOIN shrdgmr ON t1.sorlcur_pidm = shrdgmr_pidm AND t1.sorlcur_key_seqno = shrdgmr_stsp_key_sequence
    LEFT JOIN shrdgih ON shrdgmr_pidm = shrdgih_pidm AND shrdgmr_seq_no = shrdgih_dgmr_seq_no
    LEFT JOIN shrdgcm ON shrdgmr_pidm = shrdgcm_pidm AND shrdgmr_seq_no = shrdgcm_dgmr_seq_no
    
WHERE
    1=1
    
    -- Limit to UMP students
    AND (ump_1 IS NOT NULL OR sorlcur_program IN ('CHEU','DHEU'))
    
    -- Limit to current sorlcur records
    AND t1.sorlcur_term_code = (
        SELECT MAX(t2.sorlcur_term_code)
        FROM sorlcur t2
        WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER')
    AND t1.sorlcur_current_cde = 'Y'
    AND t1.sorlcur_cact_code = 'ACTIVE'
    AND t1.sorlcur_lmod_code = 'LEARNER'
    
    -- Limit to current EC decisions and pending awards
    AND ((shrapsp_term_code = '201909' AND shrapsp_activity_date >= '01-JAN-2020') OR (shrdgmr_degs_code = 'PN' AND shrapsp_term_code IS NULL))
    
ORDER BY
    "Exam_Book",
    "Faculty",
    "Faculty_Code",
    "Programme_of_Study",
    "Student_Name",
    "Current_Stage"
;