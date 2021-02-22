/*
*
* New full-time students to be data tidied
*
*/

SELECT 
	spriden_id,
	a1.*
FROM 
	sorlcur a1
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
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
		
	-- Exclude VSMS programmes
	AND a1.sorlcur_program NOT LIKE ('%-V')
		
	-- Limit to 202009 admit term	
	AND a1.sorlcur_term_code_admit = '202101'
	
	-- Limit returned students based on start date to exclude entry points later in semester
	AND a1.sorlcur_start_date < '15-FEB-2021'
	
	-- Limit to specified campuses
	-- AND a1.sorlcur_camp_code IN ('OBO','OBS','DL')
	
	-- Limit to specified mode of study
	-- AND a1.sorlcur_styp_code = 'F'
	
	-- Exclude students who are 'EN' for the study path in 202009
	AND a1.sorlcur_pidm || a1.sorlcur_key_seqno NOT IN (
	
		SELECT sfrensp_pidm || sfrensp_key_seqno
		FROM sfrensp
		WHERE
			1=1
			AND sfrensp_term_code = '202101'
			AND sfrensp_ests_code IN ('EN', 'WD', 'NS', 'AT')
	
	)
	
	-- Exclude students who are 'EN' at the learner level in 202009
	AND a1.sorlcur_pidm || a1.sorlcur_key_seqno NOT IN (
	
		SELECT sfbetrm_pidm
		FROM sfbetrm
		WHERE
			1=1
			AND sfbetrm_term_code = '202101'
			AND sfbetrm_ests_code IN ('EN', 'WD', 'NS', 'AT')
	
	)
	
	-- Exclude specified students
	AND spriden_id NOT IN (
		'19133177',
		'19061374', 
		'19132719'
	
	)
	
	
;