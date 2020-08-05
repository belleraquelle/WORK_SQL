SELECT DISTINCT
	spriden_id, 
	spriden_last_name, 
	spriden_first_name,
	s1.sorlcur_program,
	s1.sorlcur_end_date,
	sfbetrm.*
	
FROM 
	sfbetrm 
	JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur s1 ON sfbetrm_pidm = s1.sorlcur_pidm
WHERE 
	1=1
	AND sfbetrm_ests_code = 'WD' 
	AND sfbetrm_ests_date BETWEEN '01-SEP-2019' AND '31-DEC-2019' AND sfbetrm_rgre_code LIKE 'X%'
	AND s1.sorlcur_lmod_code = 'LEARNER'
	AND s1.sorlcur_cact_code = 'ACTIVE'
	AND s1.sorlcur_current_cde = 'Y'
	AND s1.sorlcur_term_code = ( 
	
		SELECT MAX(s2.sorlcur_term_code)
		FROM sorlcur s2
		WHERE 
			1=1
			AND s1.sorlcur_pidm = s2.sorlcur_pidm
			AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno
			AND s2.sorlcur_lmod_code = 'LEARNER'
			AND s2.sorlcur_cact_code = 'ACTIVE'
			AND s2.sorlcur_current_cde = 'Y'
	
	)
	AND s1.sorlcur_program IS NOT NULL
	AND s1.sorlcur_end_date > '31-AUG-2019'
ORDER BY 
	spriden_last_name
	
	;