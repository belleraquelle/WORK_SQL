SELECT 
	spriden_id,
	spriden_last_name,
	spriden_first_name,
	shrdgmr_pidm, 
	--shrdgmr_degc_code,
	--shrdgmr_degs_code,
	--shrdgih_honr_code,
	--shrdgmr_grad_date,
	shrdgmr_program,
	shrtckn_subj_code||shrtckn_crse_numb,
	shrtckn_crse_title,
	CASE 
		WHEN shrcmrk_percentage IS NOT NULL THEN shrcmrk_percentage
		ELSE to_number(shrtckn_course_comment)
	END AS "Module_Mark",
	shrdgcm_comment AS "Overall_Average"
	
FROM 
	shrdgmr 
	JOIN spriden ON shrdgmr_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN shrdgih ON shrdgmr_pidm = shrdgih_pidm AND shrdgmr_seq_no = shrdgih_dgmr_seq_no
	JOIN shrtckn ON shrdgmr_pidm = shrtckn_pidm AND shrdgmr_stsp_key_sequence = shrtckn_stsp_key_sequence
	JOIN shrdgcm ON shrdgmr_pidm = shrdgcm_pidm AND shrdgmr_seq_no = shrdgcm_dgmr_seq_no
	LEFT JOIN shrcmrk ON shrtckn_pidm = shrcmrk_pidm AND shrtckn_term_code = shrcmrk_term_code AND shrtckn_crn = shrcmrk_crn
	
WHERE
	1=1
	AND shrdgmr_program LIKE '%PX%'
	AND shrdgmr_grad_date >= '01-JUN-20'
	AND shrdgmr_degs_code = 'AW'
	
ORDER BY 	
	shrdgmr_grad_date,
	spriden_last_name,
	spriden_first_name,
	shrtckn_crse_numb,
	shrtckn_subj_code || shrtckn_crse_numb
;
