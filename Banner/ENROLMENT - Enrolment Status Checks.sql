SELECT
	spriden_id,
	c1.sgbstdn_scpc_code,
	b1.sorlcur_end_date,
	a1.sfbetrm_term_code,
	a1.sfbetrm_pidm,
	a1.sfbetrm_ests_code,
	a2.sfbetrm_term_code,
	a2.sfbetrm_ests_code
--	sfrensp_key_seqno,
--	sfrensp_ests_code
FROM 
	sfbetrm a1
	--JOIN sfrensp ON sfbetrm_term_code = sfrensp_term_code AND sfbetrm_pidm = sfrensp_pidm
	JOIN sfbetrm a2 ON a1.sfbetrm_pidm = a2.sfbetrm_pidm
	JOIN spriden ON a1.sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur b1 ON a1.sfbetrm_pidm = b1.sorlcur_pidm 
	JOIN sgbstdn c1 ON a1.sfbetrm_pidm = c1.sgbstdn_pidm
WHERE 
	1=1
	AND a1.sfbetrm_term_code = '202009'
	AND a2.sfbetrm_term_code = '202101'
	AND a1.sfbetrm_ests_code != a2.sfbetrm_ests_code
	
	
	AND b1.sorlcur_lmod_code = 'LEARNER'
	AND b1.sorlcur_cact_code = 'ACTIVE'
	AND b1.sorlcur_current_cde = 'Y'
	AND b1.sorlcur_term_code_end IS NULL
	AND b1.sorlcur_term_code = ( 
	
		SELECT MAX(b2.sorlcur_term_code)
		FROM sorlcur b2
		WHERE
			1=1
			AND b1.sorlcur_pidm = b2.sorlcur_pidm 
			AND b2.sorlcur_lmod_code = 'LEARNER'
			AND b2.sorlcur_cact_code = 'ACTIVE'
			AND b2.sorlcur_current_cde = 'Y'
			AND b2.sorlcur_term_code_end IS NULL 
	
	)
	
	AND c1.sgbstdn_term_code_eff = (
	
		SELECT MAX(c2.sgbstdn_term_code_eff)
		FROM sgbstdn c2
		WHERE c1.sgbstdn_pidm = c2.sgbstdn_pidm
	
	)
	
	
	AND a1.sfbetrm_ests_code = 'EN'
	AND b1.sorlcur_end_date > '31-DEC-20'
	AND c1.sgbstdn_scpc_code = 'AUTUMN'
	