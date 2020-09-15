SELECT 
	spriden_id, 
	sorlcur_key_seqno,
	sorlcur_program,
	sgrsatt_term_code_eff,
	sgrsatt_atts_code
FROM
	sorlcur
	LEFT JOIN sgrsatt ON sorlcur_pidm = sgrsatt_pidm AND sorlcur_key_seqno = sgrsatt_stsp_key_sequence
	JOIN spriden ON sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sgbstdn ON sorlcur_pidm = sgbstdn_pidm
WHERE 
	1=1
	AND sorlcur_lmod_code = 'LEARNER'
	AND sorlcur_term_code_end IS NULL
	AND sorlcur_term_code_admit = '202009'
	AND (sgrsatt_term_code_eff = '202009' OR sgrsatt_term_code_eff IS NULL)
	AND sgrsatt_atts_code IS NULL
	AND sgbstdn_term_code_eff = '202009'
	AND sgbstdn_stst_code = 'AS'
ORDER BY 
	spriden_id
;