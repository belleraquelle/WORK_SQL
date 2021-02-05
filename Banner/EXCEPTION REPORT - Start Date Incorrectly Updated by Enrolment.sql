SELECT DISTINCT
	spriden_id,
	s1.sorlcur_key_seqno,
	s1.sorlcur_lmod_code,
	s1.sorlcur_seqno,
	s1.sorlcur_program,
	s1.sorlcur_start_date AS "Current 'Incorrect' Start Date",
	x1.sorlcur_start_date AS "Original Start Date"
FROM 
	sorlcur s1
	JOIN sorlcur x1 ON s1.sorlcur_pidm = x1.sorlcur_pidm AND s1.sorlcur_key_seqno = x1.sorlcur_key_seqno
	JOIN spriden ON s1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	AND s1.sorlcur_lmod_code = 'LEARNER'
	AND s1.sorlcur_current_cde = 'Y'
	AND s1.sorlcur_cact_code = 'ACTIVE'
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
	AND s1.sorlcur_end_date > sysdate
	AND x1.sorlcur_lmod_code = 'LEARNER'
	AND x1.sorlcur_current_cde = 'Y'
	AND x1.sorlcur_cact_code = 'ACTIVE'
	AND x1.sorlcur_term_code = (
		SELECT MIN(x2.sorlcur_term_code)
		FROM sorlcur x2
		WHERE 
			1=1
			AND x1.sorlcur_pidm = x2.sorlcur_pidm
			AND x1.sorlcur_key_seqno = x2.sorlcur_key_seqno
			AND x2.sorlcur_lmod_code = 'LEARNER'
			AND x2.sorlcur_cact_code = 'ACTIVE'
			AND x2.sorlcur_current_cde = 'Y'		
	)
	AND x1.sorlcur_start_date != s1.sorlcur_start_date
	AND s1.sorlcur_start_date >= '01-JAN-2021'
	
;