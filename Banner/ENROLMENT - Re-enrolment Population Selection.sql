/*

Re-enrolment Population Selection

*/

SELECT DISTINCT
    d1.spriden_id AS "Student_ID",
    t1.sgrstsp_pidm AS "Student_PIDM",
    d1.spriden_last_name AS "Last_Name", 
    d1.spriden_first_name AS "First_Name",
    t1.sgrstsp_key_seqno AS "Study_Path",
    --t1.sgrstsp_term_code_eff,
    --t1.sgrstsp_stsp_code,
    t2.sorlcur_term_code_admit AS "Admit_Term",
    t4.sgbstdn_resd_code AS "Residency",
    --t2.sorlcur_key_seqno,
    --t2.sorlcur_priority_no,
    t2.sorlcur_coll_code AS "Faculty",
    t2.sorlcur_levl_code AS "Level",
    t2.sorlcur_program AS "Programme",
    t2.sorlcur_styp_code AS "Mode_of_Study",
    t2.sorlcur_end_date AS "Expected_End_Date",
    --t2.sorlcur_term_code AS "Sorlcur_Term_Code",
    --t2.sorlcur_term_code_end AS "Sorlcur_Term_Code_End",
    --t2.sorlcur_curr_rule,
    --t3.sorlfos_csts_code,
    --t4.sgbstdn_term_code_eff,
    --tbraccd_detail_code,
    SUM(tbraccd_amount) AS "Fees"
    --t4.acenrol_status_1,
    --t4.finenrol_status_1,
    --t4.overall_enrol_status_1
FROM
    sgrstsp t1
    JOIN sorlcur t2 ON (t1.sgrstsp_pidm = t2.sorlcur_pidm AND t1.sgrstsp_key_seqno = t2.sorlcur_key_seqno)
    JOIN sorlfos t3 ON (t2.sorlcur_pidm = t3.sorlfos_pidm AND t2.sorlcur_seqno = t3.sorlfos_lcur_seqno)
    JOIN spriden d1 ON (t1.sgrstsp_pidm = d1.spriden_pidm)
    JOIN sgbstdn_add t4 ON (t1.sgrstsp_pidm = t4.sgbstdn_pidm)
    LEFT JOIN tbraccd ON tbraccd_pidm = t1.sgrstsp_pidm
WHERE
    1=1
	-- CURRENT STUDENT NUMBER AND NOT TEST
    AND d1.spriden_change_ind IS NULL
    AND (d1.spriden_ntyp_code IS NULL OR d1.spriden_ntyp_code != 'TEST')
    
	-- IDENTIFY STUDENTS WITH ACTIVE STUDY PATHS
    AND t1.sgrstsp_term_code_eff = (
        SELECT MAX(a2.sgrstsp_term_code_eff)
        FROM sgrstsp a2
        WHERE t1.sgrstsp_pidm = a2.sgrstsp_pidm AND t1.sgrstsp_key_seqno = a2.sgrstsp_key_seqno
    )
    AND t1.sgrstsp_stsp_code = 'AS'
    
	-- ONLY INCLUDE STUDY PATHS WITH A COMPLETION DATE BEYOND MASTERS DISSERTATION SUBMISSION DEADLINE
    AND t2.sorlcur_term_code = (
        SELECT MAX(b2.sorlcur_term_code)
        FROM sorlcur b2
        WHERE t2.sorlcur_pidm = b2.sorlcur_pidm AND t2.sorlcur_key_seqno = b2.sorlcur_key_seqno
        AND t2.sorlcur_lmod_code = 'LEARNER' AND t2.sorlcur_end_date >= :next_pg_dissertation_deadline
    )
    AND t2.sorlcur_lmod_code = 'LEARNER' AND t2.sorlcur_end_date > :completion_date_is_greater_than
    AND t2.sorlcur_camp_code NOT IN ('AIE')
    
	-- LIMIT TO CURRENT SGBSTDN RECORD
    AND t4.sgbstdn_term_code_eff = (
        SELECT MAX(e2.sgbstdn_term_code_eff)
        FROM sgbstdn e2
        WHERE t4.sgbstdn_pidm = e2.sgbstdn_pidm
    )
    AND sgbstdn_stst_code = 'AS'
    
	-- ONLY INCLUDE PROPER SORLCUR RECORDS
    AND t3.SORLFOS_csts_code = 'INPROGRESS'
    AND t2.sorlcur_current_cde = 'Y'
    AND t2.sorlcur_term_code_end IS NULL
    
	-- EXCLUDE STUDENTS WHO ARE ALREADY EN/AT/UT/WD FOR THE ENROLMENT TERM
    AND t1.sgrstsp_pidm NOT IN (
        SELECT sfrensp_pidm FROM sfrensp WHERE sfrensp_term_code = :term_for_enrolment AND sfrensp_ests_code IN ('AT', 'EN', 'UT', 'WD', 'XF')
    )
    
	-- LIMIT TO STUDENTS WHO HAVE A FINAL STATUS FOR PREVIOUS TERM
    AND t1.sgrstsp_pidm IN (
        SELECT sfrensp_pidm FROM sfrensp WHERE sfrensp_term_code = :term_before_term_for_enrolment AND sfrensp_ests_code IN ('AT', 'EN', 'UT')
    )
    
	-- EXCLUDE NEW STUDENTS
    AND t2.sorlcur_term_code_admit != :term_for_enrolment
	-- ONLY INCLUDE STUDENTS WHO HAVE NOT BEEN OPENED FOR ENROLMENT YET
	-- AND t4.acenrol_status_1 IS NULL
	--AND spriden_id = '17088151'
	
    -- Limit TBRACCD to enrolment term
    AND (tbraccd_term_code = :term_for_enrolment OR tbraccd_term_code IS NULL)
    AND (TBRACCD_DETAIL_CODE IN (SELECT TBBDETC_DETAIL_CODE FROM TBBDETC WHERE TBBDETC_DCAT_CODE = 'TUI') OR tbraccd_detail_code IS NULL)

GROUP BY
	d1.spriden_id,
    t1.sgrstsp_pidm,
    d1.spriden_last_name, 
    d1.spriden_first_name,
    t1.sgrstsp_key_seqno,
    --t1.sgrstsp_term_code_eff,
    --t1.sgrstsp_stsp_code,
    t2.sorlcur_term_code_admit,
    t4.sgbstdn_resd_code,
    --t2.sorlcur_key_seqno,
    --t2.sorlcur_priority_no,
    t2.sorlcur_coll_code,
    t2.sorlcur_levl_code,
    t2.sorlcur_program,
    t2.sorlcur_end_date,
    t2.sorlcur_styp_code
    --t2.sorlcur_term_code,
    --t2.sorlcur_term_code_end,
    --t2.sorlcur_curr_rule,
    --t3.sorlfos_csts_code,
    --t4.sgbstdn_term_code_eff
    
ORDER BY
    sorlcur_program,
    sorlcur_end_date ASC
;