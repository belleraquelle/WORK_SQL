-- 'New' students who need to be on the finance list. Will include early links and foundation progressions

SELECT DISTINCT
	spriden_id, a1.*
FROM
	sorlcur a1
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	AND a1.sorlcur_lmod_code = 'LEARNER'
	AND a1.sorlcur_cact_code = 'ACTIVE'
	AND a1.sorlcur_current_cde = 'Y'
	AND a1.sorlcur_term_code_admit = '202009'
	AND a1.sorlcur_pidm NOT IN ( 
	
		SELECT glbextr_key
		FROM glbextr
		WHERE glbextr_selection IN (  
			'20200817_LINK'
			--'20200824_LINK'
		)
	
	);