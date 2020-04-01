SELECT DISTINCT
	spriden_id,
	shrapsp_term_code,
	shrapsp_astd_code_end_of_term
FROM 
	shrapsp shrapsp1 
	JOIN spriden ON shrapsp_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1 
	AND shrapsp1.shrapsp_term_code = (
		SELECT MAX(shrapsp2.shrapsp_term_code)
		FROM shrapsp shrapsp2
		WHERE shrapsp1.shrapsp_pidm = shrapsp2.shrapsp_pidm AND shrapsp1.shrapsp_stsp_key_sequence = shrapsp2.shrapsp_stsp_key_sequence
	)
	AND shrapsp1.shrapsp_astd_code_end_of_term = 'AF'
	AND shrapsp1.shrapsp_term_code >= '201909'
;