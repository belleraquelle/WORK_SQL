/*
 * This query identifies continuing students who have not completed enrolment and so need to be put on UTWD 
 */

SELECT 
	spriden_id,
	a1.*,
	szrenrl.*
FROM 
	sorlcur a1
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
	LEFT JOIN szrenrl ON a1.sorlcur_pidm = szrenrl_pidm
	JOIN sgrstsp t1 ON a1.sorlcur_pidm = t1.sgrstsp_pidm AND a1.sorlcur_key_seqno = t1.sgrstsp_key_seqno
	JOIN sgbstdn_add t4 ON a1.sorlcur_pidm = t4.sgbstdn_pidm
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
		
	-- Exclude new students based on admit term	
	AND a1.sorlcur_term_code_admit != '202009'
	
	-- Limit to students with a completion date in the future that is beyond the PG dissertation deadline
	AND a1.sorlcur_end_date > '30-SEP-2020'
	
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
    AND a1.sorlcur_camp_code NOT IN ('AIE')
    
    -- Exclude Research students
    AND a1.sorlcur_levl_code != 'RD'
	
	-- Exclude students who are 'EN' for the study path in 202009
	AND a1.sorlcur_pidm || a1.sorlcur_key_seqno NOT IN (
	
		SELECT sfrensp_pidm || sfrensp_key_seqno
		FROM sfrensp
		WHERE
			1=1
			AND sfrensp_term_code = '202009'
			AND sfrensp_ests_code IN ('EN', 'WD', 'NS', 'AT', 'UT')
	
	)
	
	-- Exclude students who are 'EN' at the learner level in 202009
	AND a1.sorlcur_pidm || a1.sorlcur_key_seqno NOT IN (
	
		SELECT sfbetrm_pidm
		FROM sfbetrm
		WHERE
			1=1
			AND sfbetrm_term_code = '202009'
			AND sfbetrm_ests_code IN ('EN', 'WD', 'NS', 'AT', 'UT')
	
	)
	
	-- Exclude students who have completed academic and financial enrolment
	AND a1.sorlcur_pidm NOT IN ( 
	
		SELECT szrenrl_pidm
		FROM szrenrl
		WHERE
			1=1
			AND szrenrl_term_code = '202009'
			AND szrenrl_academic_enrol_status = 'CO'
			AND szrenrl_financial_enrol_status = 'CO'
			AND szrenrl_overall_enrol_status = 'CO'
	
	)	
	
ORDER BY 
	a1.sorlcur_camp_code,
	a1.sorlcur_program
;