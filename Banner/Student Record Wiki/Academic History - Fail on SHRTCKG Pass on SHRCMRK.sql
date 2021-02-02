SELECT
	spriden_id,
	shrtckn_term_code,
	shrtckn_subj_code,
	shrtckn_crse_numb, 
	shrtckg_grde_code_final,
	shrcmrk_grde_code
FROM 
	shrtckn
	JOIN shrcmrk ON shrtckn_pidm = shrcmrk_pidm AND shrtckn_term_code = shrcmrk_term_code AND shrtckn_crn = shrcmrk_crn
	JOIN shrtckg a1 ON shrtckn_pidm = a1.shrtckg_pidm AND shrtckn_term_code = a1.shrtckg_term_code AND shrtckn_seq_no = a1.shrtckg_tckn_seq_no
	JOIN spriden ON shrtckn_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	AND a1.shrtckg_seq_no = (
		SELECT MAX(a2.shrtckg_seq_no) 
		FROM shrtckg a2 
		WHERE a1.shrtckg_pidm = a2.shrtckg_pidm AND a1.shrtckg_term_code = a2.shrtckg_term_code AND a1.shrtckg_tckn_seq_no = a2.shrtckg_tckn_seq_no
	)
	AND shrtckg_grde_code_final IN (
		SELECT shrgrde_code FROM shrgrde WHERE shrgrde_passed_ind = 'N'
	)
	
	AND shrcmrk_grde_code IN (
		SELECT shrgrde_code FROM shrgrde WHERE shrgrde_passed_ind = 'Y'
	)
ORDER BY 
	shrtckn_term_code,
	spriden_id
;