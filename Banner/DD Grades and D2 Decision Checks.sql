SELECT
	spriden_id,
	shrtckg_pidm || shrtckn_stsp_key_sequence,
	shrtckg_term_code,
	shrtckn_crn,
	shrtckg_grde_code_final,
	shrapsp_term_code,
	shrapsp_astd_code_end_of_term
	
FROM 
	shrtckg a1
	JOIN shrtckn b1 ON a1.shrtckg_tckn_seq_no = b1.shrtckn_seq_no 
		AND a1.shrtckg_pidm = b1.shrtckn_pidm 
		AND a1.shrtckg_term_code = b1.shrtckn_term_code
	JOIN spriden ON shrtckg_pidm = spriden_pidm AND spriden_change_ind IS NULL
	LEFT JOIN shrapsp ON a1.shrtckg_pidm = shrapsp_pidm
WHERE
	1=1
	
	AND a1.shrtckg_seq_no = ( 
	
	SELECT MAX(a2.shrtckg_seq_no)
	FROM shrtckg a2
	WHERE 
		a1.shrtckg_pidm = a2.shrtckg_pidm 
		AND a1.shrtckg_term_code = a2.shrtckg_term_code
		AND a1.shrtckg_tckn_seq_no = a2.shrtckg_tckn_seq_no
	
	)
	
	AND a1.shrtckg_grde_code_final = 'DD'
	
	-- Limit to records in specified popsel
	AND a1.shrtckg_pidm IN (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = :popsel_name AND glbextr_user_id = :popsel_user)
	
	AND (shrapsp_term_code = '202001' OR shrapsp_term_code IS NULL)
;


SELECT
	spriden_id,
	shrapsp_term_code,
	shrapsp_astd_code_end_of_term
FROM 
	spriden
	JOIN shrapsp ON spriden_pidm = shrapsp_pidm
WHERE 
	spriden_change_ind IS NULL 
	AND shrapsp_term_code = '202001'
	AND shrapsp_astd_code_end_of_term = 'D2'
	AND shrapsp_pidm NOT IN (
	
		SELECT a1.shrtckg_pidm
		FROM shrtckg a1
		WHERE
			a1.shrtckg_seq_no = ( 
	
				SELECT MAX(a2.shrtckg_seq_no)
				FROM shrtckg a2
				WHERE 
					a1.shrtckg_pidm = a2.shrtckg_pidm 
					AND a1.shrtckg_term_code = a2.shrtckg_term_code
					AND a1.shrtckg_tckn_seq_no = a2.shrtckg_tckn_seq_no
			
			)
	
			AND a1.shrtckg_grde_code_final = 'DD'
	
	)
	
	
;