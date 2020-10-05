/*
*
* New full-time, non-ACP students who have completed enrolment but have an overall CP code (Tier 4 Hold)
*
*/

SELECT 
	spriden_id,
	szrenrl.*,
	a1.*
FROM 
	sorlcur a1
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
	LEFT JOIN szrenrl ON a1.sorlcur_pidm = szrenrl_pidm
WHERE
	1=1
	
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
		
	-- Limit to 202009 admit term	
	AND a1.sorlcur_term_code_admit = '202009'
	
	-- Limit to specified campuses
	AND a1.sorlcur_camp_code IN ('OBO','OBS','DL')
	
	-- Limit to specified mode of study
	AND a1.sorlcur_styp_code = 'F'
	
	-- Exclude students who are 'EN' for the study path in 202009
	AND a1.sorlcur_pidm || a1.sorlcur_key_seqno NOT IN (
	
		SELECT sfrensp_pidm || sfrensp_key_seqno
		FROM sfrensp
		WHERE
			1=1
			AND sfrensp_term_code = '202009'
			AND sfrensp_ests_code IN ('EN', 'WD', 'NS', 'AT')
	
	)
	
	-- Exclude students who are 'EN' at the learner level in 202009
	AND a1.sorlcur_pidm || a1.sorlcur_key_seqno NOT IN (
	
		SELECT sfbetrm_pidm
		FROM sfbetrm
		WHERE
			1=1
			AND sfbetrm_term_code = '202009'
			AND sfbetrm_ests_code IN ('EN', 'WD', 'NS', 'AT')
	
	)
	
	-- Include students who have completed academic enrolment and financial enrolment
	AND a1.sorlcur_pidm IN ( 
	
		SELECT szrenrl_pidm
		FROM szrenrl
		WHERE
			1=1
			AND szrenrl_term_code = '202009'
			AND szrenrl_academic_enrol_status = 'CO'
			AND szrenrl_financial_enrol_status = 'CO'
			AND szrenrl_overall_enrol_status = 'CP'
	
	)
	
	-- Exclude permitted late enrollers
	AND spriden_id NOT IN (
	
		-- Degree apprenticeships
		'19144235',
		
		-- Gav's list
		'19131790',
		'18035165',
		'19141110',
		'19141128',
		'19137002',
		'19142281',
		'18059497'
	
	)
	
	
;