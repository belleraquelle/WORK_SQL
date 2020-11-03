/*
*
* New part-time, non-ACP students who have academically enrolled but not financially enrolled
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
		
	-- Exclude VSMS programmes
	AND a1.sorlcur_program NOT LIKE ('%-V')
		
	-- Limit to 202009 admit term	
	AND a1.sorlcur_term_code_admit = '202009'
	
	-- Limit to specified campuses
	AND a1.sorlcur_camp_code IN ('OBO','OBS','DL')
	
	-- Limit to specified mode of study
	AND a1.sorlcur_styp_code = 'P'
	
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
	
	-- Include students who have completed academic enrolment but not financial enrolment
	AND a1.sorlcur_pidm IN ( 
	
		SELECT szrenrl_pidm
		FROM szrenrl
		WHERE
			1=1
			AND szrenrl_term_code = '202009'
			AND szrenrl_academic_enrol_status = 'CO'
			AND (szrenrl_financial_enrol_status != 'CO' OR szrenrl_financial_enrol_status IS NULL)
	
	)
	
	-- Exclude permitted late enrollers
	AND spriden_id NOT IN (
	
		-- Degree apprenticeships
		'19144235',
		'19144633',
		
		-- Gav's list
		'19131790',
		'18035165',
		'19141110',
		'19141128',
		'19137002',
		'19142281',
		'18059497',
		'10058468',
		'19062322',
		'19142055',
		'19141721',
		'19129257',
		'19026107',
		'19141432',
		'19034481',
		'19008955',
		'17010335',
		'19068688',
		'19141335',
		'19038387',
		'19042317',
		'19144580',
		'19057073',
		'19020959',
		'19072666',
		'19135278',
		'19129663',
		'19064131',
		'19044872',
		'19141986',
		'19071403',
		'19141750',
		'19066813',
		'19028794',
		'19069414',
		'19045217',
		'19071314',
		'19139011',
		'19062353',
		'19062328',
		'19062279',
		'19061459',
		'19013945',
		'19045245',
		'19026719',
		'19031457',
		'19018400',
		'19141562',
		'19144628',
		'19042426',
		'19062279',
		'18054305',
		'19137800',
		'19131974',
		'19044871',
		'19023043',
		'19126967',
		'19143405',
		'19033434'
	
	)
	
	
;