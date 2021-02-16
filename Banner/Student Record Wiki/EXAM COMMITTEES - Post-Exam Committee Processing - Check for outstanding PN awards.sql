SELECT DISTINCT
	spriden_pidm, spriden_id, s1.sorlcur_program, shrdgmr.*
FROM 
	shrdgmr,
	sorlcur s1,
	sobcurr_add,
	spriden
WHERE 
	1=1
	AND shrdgmr_pidm = s1.sorlcur_pidm AND shrdgmr_seq_no = s1.sorlcur_key_seqno AND s1.sorlcur_lmod_code = 'OUTCOME'
	AND shrdgmr_pidm = spriden_pidm AND spriden_change_ind IS NULL
	AND s1.sorlcur_curr_rule = sobcurr_curr_rule
	AND ump_1 = 'Y'
	AND shrdgmr_degs_code = 'PN'
ORDER BY spriden_pidm, shrdgmr_stsp_key_sequence, shrdgmr_seq_no
;
			