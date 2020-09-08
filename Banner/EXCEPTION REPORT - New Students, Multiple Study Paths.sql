SELECT DISTINCT
	spriden_id,
	spriden_last_name, 
	spriden_first_name,
	s1.sorlcur_term_code_admit,
	s1.sorlcur_program
	--s2.sorlcur_term_code_admit,
	--s2.sorlcur_program
FROM 
	sorlcur s1
	JOIN sorlcur s2 ON s1.sorlcur_pidm = s2.sorlcur_pidm
	JOIN spriden ON s1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	s1.sorlcur_term_code_admit = '202009'
	AND s2.sorlcur_term_code_admit = '202009'
	AND s1.sorlcur_lmod_code = 'LEARNER'
	AND s2.sorlcur_lmod_code = 'LEARNER'
	AND s1.sorlcur_key_seqno != s2.sorlcur_key_seqno
	AND s1.sorlcur_term_code_end IS NULL
	AND s2.sorlcur_term_code_end IS NULL
	--AND s1.sorlcur_program = s2.sorlcur_program
ORDER BY 
	spriden_id