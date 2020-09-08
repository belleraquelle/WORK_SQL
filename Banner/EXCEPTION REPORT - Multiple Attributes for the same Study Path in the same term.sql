/*
* Multiple attributes for the same study path in the same term
*/

SELECT DISTINCT
	spriden_id
--	a1.sgrsatt_pidm,
--	a1.sgrsatt_term_code_eff,
--	a1.sgrsatt_stsp_key_sequence,
--	a1.sgrsatt_atts_code,
--	b1.sgrsatt_term_code_eff,
--	b1.sgrsatt_stsp_key_sequence,
--	b1.sgrsatt_atts_code
FROM 
	sgrsatt a1
	JOIN sgrsatt b1 ON a1.sgrsatt_pidm = b1.sgrsatt_pidm 
		AND a1.sgrsatt_term_code_eff = b1.sgrsatt_term_code_eff
		AND a1.sgrsatt_stsp_key_sequence = b1.sgrsatt_stsp_key_sequence
		AND a1.sgrsatt_atts_code != b1.sgrsatt_atts_code
	JOIN spriden ON a1.sgrsatt_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	AND a1.sgrsatt_term_code_eff = '202009'
;
