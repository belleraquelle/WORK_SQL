SELECT DISTINCT
	spriden_id, 
	a1.sorlcur_program AS "Learner_Programme",
	a1.sorlcur_end_date AS "Learner_End_Date", 
	shrdgmr_degs_code,
	o1.sorlcur_program AS "Outcome_Programme",
	o1.sorlcur_end_date AS "Outcome_End_Date",
	o1.sorlcur_seqno,
	s1.*
FROM 
	sgrsatt s1
	JOIN spriden ON s1.sgrsatt_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN shrtckn ON s1.sgrsatt_pidm = shrtckn_pidm AND s1.sgrsatt_stsp_key_sequence = shrtckn_stsp_key_sequence
	JOIN sorlcur a1 ON a1.sorlcur_lmod_code = 'LEARNER' AND s1.sgrsatt_pidm = a1.sorlcur_pidm AND s1.sgrsatt_stsp_key_sequence = a1.sorlcur_key_seqno
	LEFT JOIN shrdgmr ON s1.sgrsatt_pidm = shrdgmr_pidm AND s1.sgrsatt_stsp_key_sequence = shrdgmr_stsp_key_sequence
	LEFT JOIN sorlcur o1 ON o1.sorlcur_lmod_code = 'OUTCOME' AND shrdgmr_pidm = o1.sorlcur_pidm AND shrdgmr_seq_no = o1.sorlcur_key_seqno
WHERE
	1=1
	AND a1.sorlcur_cact_code = 'ACTIVE'
	AND a1.sorlcur_current_cde = 'Y'
	AND a1.sorlcur_term_code = (
		SELECT MAX(a2.sorlcur_term_code)
		FROM sorlcur a2
		WHERE 
			a2.sorlcur_pidm = a1.sorlcur_pidm 
			AND a2.sorlcur_key_seqno = a1.sorlcur_key_seqno 
			AND a2.sorlcur_lmod_code = 'LEARNER' 
			AND a2.sorlcur_current_cde = 'Y'
			AND a2.sorlcur_cact_code = 'ACTIVE'
	)
	AND (o1.sorlcur_seqno IS NULL OR o1.sorlcur_seqno = (
		SELECT MAX(o2.sorlcur_seqno)
		FROM sorlcur o2
		WHERE
			o1.sorlcur_pidm = o2.sorlcur_pidm 
			AND o1.sorlcur_key_seqno = o2.sorlcur_key_seqno
			AND o2.sorlcur_lmod_code = 'OUTCOME'
	))
	AND s1.sgrsatt_atts_code = 'S1'
	AND s1.sgrsatt_pidm || s1.sgrsatt_stsp_key_sequence IN (
		SELECT s2.sgrsatt_pidm || s2.sgrsatt_stsp_key_sequence
		FROM sgrsatt s2
		WHERE s2.sgrsatt_atts_code = 'X1'
	)
	AND shrtckn_crse_numb LIKE '3___'
	AND a1.sorlcur_program NOT LIKE 'F%'
	AND (o1.sorlcur_program NOT LIKE 'F%' OR o1.sorlcur_program IS NULL)
	--AND spriden_id = '14068359'
ORDER BY 	
	spriden_id
;

SELECT * FROM sorlcur;