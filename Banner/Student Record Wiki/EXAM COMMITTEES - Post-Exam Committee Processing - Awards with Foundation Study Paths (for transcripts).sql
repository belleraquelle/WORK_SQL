SELECT 
	spriden_id, 
	s1.sorlcur_program,
	shrdgmr_stsp_key_sequence
FROM 
	shrdgmr
	JOIN sorlcur s1 ON shrdgmr_pidm = s1.sorlcur_pidm AND shrdgmr_seq_no = s1.sorlcur_key_seqno 
	JOIN spriden ON spriden_pidm = shrdgmr_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	AND s1.sorlcur_lmod_code = 'OUTCOME'
	AND s1.sorlcur_seqno = (
		SELECT MAX(s2.sorlcur_seqno)
		FROM sorlcur s2
		WHERE s1.sorlcur_pidm = s2.sorlcur_pidm 
			AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno 
			AND s2.sorlcur_lmod_code = 'OUTCOME'
	)
	AND shrdgmr_grad_date BETWEEN '01-JAN-2021' AND '31-JAN-2021'
	AND shrdgmr_degs_code = 'AW'
	AND s1.sorlcur_levl_code = 'UG'
	AND s1.sorlcur_program NOT LIKE 'FNDIP%'
	AND s1.sorlcur_program NOT LIKE 'UGASSO%'
	AND shrdgmr_pidm IN (
		SELECT sorlcur_pidm
		FROM sorlcur
		WHERE sorlcur_lmod_code = 'LEARNER' AND sorlcur_program LIKE 'FNDIP%'
		)
ORDER BY 
	s1.sorlcur_program	
;
