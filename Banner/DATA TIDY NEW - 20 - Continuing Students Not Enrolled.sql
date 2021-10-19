/*
 * This query identifies continuing students who have not completed enrolment and so need to be put on UTWD 
 * Updated 18-OCT-2021 - SRC
 */

SELECT 
	spriden_id AS "Student_Number",
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    CASE WHEN sprhold_hldd_code = 'RX' THEN 'Y' END AS "Current_RX_Hold",
    t4.sgbstdn_stst_code AS "Current_Student_Status",
    a1.sorlcur_camp_code AS "Campus",
    a1.sorlcur_program AS "Programme_Code",
    smrprle_program_desc AS "Programme_Description",
    to_char(a1.sorlcur_start_date,'DD-MON-YYYY') AS "Start_Date",
    to_char(a1.sorlcur_end_date, 'DD-MON-YYYY') AS "Expected_Completion_Date",
    szrenrl_academic_enrol_status AS "Academic_Enrolment_Status", 
    szrenrl_financial_enrol_status AS "Financial_Enrolment_Status",
    szrenrl_overall_enrol_status AS "Overall_Enrolment_Status"
FROM 
	sorlcur a1
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
	LEFT JOIN szrenrl ON a1.sorlcur_pidm = szrenrl_pidm AND szrenrl_term_code = :term_code
	JOIN sgrstsp t1 ON a1.sorlcur_pidm = t1.sgrstsp_pidm AND a1.sorlcur_key_seqno = t1.sgrstsp_key_seqno
	JOIN sgbstdn t4 ON a1.sorlcur_pidm = t4.sgbstdn_pidm
    JOIN smrprle ON a1.sorlcur_program = smrprle_program
    LEFT JOIN sprhold ON a1.sorlcur_pidm = sprhold_pidm AND sprhold_hldd_code = 'RX' AND sysdate BETWEEN sprhold_from_date AND sprhold_to_date
WHERE
	1=1
	
	-- Exclude Test Students
	AND (spriden_ntyp_code IS NULL OR spriden_ntyp_code != 'TEST')
	
	-- Exclude VSMS programmes
	AND a1.sorlcur_program NOT LIKE ('%-V')
	
	-- SORLCUR requirements  
	AND a1.sorlcur_lmod_code = 'LEARNER'
	AND a1.sorlcur_cact_code = 'ACTIVE'
	AND a1.sorlcur_current_cde = 'Y'
	AND a1.sorlcur_term_code = ( 
		
		SELECT MAX(a2.sorlcur_term_code)
		FROM sorlcur a2
		WHERE
			1=1
			AND a1.sorlcur_pidm = a2.sorlcur_pidm
			AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno
			AND a2.sorlcur_lmod_code = 'LEARNER'
			AND a2.sorlcur_cact_code = 'ACTIVE'
			AND a2.sorlcur_current_cde = 'Y'
	
		)
		
	-- Exclude study paths where max active has an end term
	AND a1.sorlcur_term_code_end IS NULL
		
	-- Exclude new students based on admit term	
	AND a1.sorlcur_term_code_admit != :term_code
	
	-- Limit to students with a completion date in the future that is beyond the PG dissertation deadline
	AND a1.sorlcur_end_date > :PG_dissertation_deadline
	
	-- Current student status is Active
    AND t4.sgbstdn_term_code_eff = (
        SELECT MAX(e2.sgbstdn_term_code_eff)
        FROM sgbstdn e2
        WHERE t4.sgbstdn_pidm = e2.sgbstdn_pidm
    )
    AND sgbstdn_stst_code = 'AS'
    
    -- Current study path status is Active
    AND t1.sgrstsp_term_code_eff = (
        SELECT MAX(a2.sgrstsp_term_code_eff)
        FROM sgrstsp a2
        WHERE t1.sgrstsp_pidm = a2.sgrstsp_pidm AND t1.sgrstsp_key_seqno = a2.sgrstsp_key_seqno
    )
    AND t1.sgrstsp_stsp_code = 'AS'
    
    -- Exclude AIE students
    AND a1.sorlcur_camp_code NOT IN ('AIE', 'CD')
    
    -- Exclude Research students
    --AND a1.sorlcur_levl_code != 'RD'
	
	-- Exclude students who have a valid final enrolment status for the study path in specified term
	AND a1.sorlcur_pidm || a1.sorlcur_key_seqno NOT IN (
	
		SELECT sfrensp_pidm || sfrensp_key_seqno
		FROM sfrensp
		WHERE
			1=1
			AND sfrensp_term_code = :term_code
			AND sfrensp_ests_code IN ('EN', 'WD', 'NS', 'AT', 'UT')
	
	)
	
	-- Exclude students who have a valid final enrolment status at the learner level in specified term
	AND a1.sorlcur_pidm NOT IN (
	
		SELECT sfbetrm_pidm
		FROM sfbetrm
		WHERE
			1=1
			AND sfbetrm_term_code = : term_code
			AND sfbetrm_ests_code IN ('EN', 'WD', 'NS', 'AT', 'UT')
	
	)
    
    -- Exclude specified students
	AND spriden_id NOT IN (
        '19189574',
        '19061404',
        '19191738',
        '19186855',
        '19181288',
        '14058497',
        '19061184',
        '19018564',
        '18067055',
        '19046640',
        '19141556',
        '19019852',
        '19007177',
        '19009457',
        '19140266',
        '18040955',
        '19022701',
        '18002754',
        '19024918',
        '18044029',
        '17077282',
        '14111488',
        '18107166',
        '19185895',
        '19146277',
        '18107526',
        '19033743',
        '18107166',
        '19176077',
        '19183626',
        '19145627',
        '19129790',
        '19184397',
        '19179575',
        '19180282',
        '19176614',
        '19179355',
        '19184740',
        '19185335',
        '19159388',
        '19138307',
        '19162663',
        '19174928',
        '19169438',
        '19179540',
        '19164884',
        '19181053',
        '19142523',
        '19169215',
        '19164883',
        '19043489',
        '19164386',
        '19051709',
        '19175479',
        '19143875',
        '19066269',
        '19142616',
        '19162565',
        '19133281',
        '19158844',
        '19026773',
        '19167461',
        '19180928',
        '19184463',
        '19162471',
        '19184255'
        )
	
    -- Limit to students without an overall enrolment status
    AND szrenrl_overall_enrol_status IS NULL
    
ORDER BY
    "Campus",
    "Programme_Code", 
    "Student_Name"
;