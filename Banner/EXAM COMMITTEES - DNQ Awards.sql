SELECT DISTINCT
	spriden_id,
	shrdgih_honr_code,
	shrapsp_astd_code_end_of_term,
	shrdgmr.*
FROM 
	shrdgmr
	JOIN spriden ON shrdgmr_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN shrdgih ON shrdgmr_pidm = shrdgih_pidm AND shrdgmr_seq_no = shrdgih_dgmr_seq_no
	LEFT JOIN shrapsp shrapsp1 ON shrdgmr_pidm = shrapsp1.shrapsp_pidm AND shrdgmr_stsp_key_sequence = shrapsp1.shrapsp_stsp_key_sequence
WHERE
	1=1 
	AND shrdgih_honr_code = 'DNQ'
	AND (shrapsp1.shrapsp_term_code = (
		SELECT MAX(shrapsp2.shrapsp_term_code)
		FROM shrapsp shrapsp2
		WHERE shrapsp1.shrapsp_pidm = shrapsp2.shrapsp_pidm AND shrapsp1.shrapsp_stsp_key_sequence = shrapsp2.shrapsp_stsp_key_sequence
	) OR shrapsp1.shrapsp_term_code IS NULL)
;