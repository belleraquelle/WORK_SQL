SELECT 
	spriden_id,
	shrtckn_term_code,
	ssbsect_crn,
	ssbsect_subj_code || ssbsect_crse_numb
FROM 
	shrtckn
	JOIN spriden ON shrtckn_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN ssbsect ON shrtckn_term_code = ssbsect_term_code AND shrtckn_crn = ssbsect_crn
	JOIN shrtckg s1 ON shrtckn_pidm = s1.shrtckg_pidm AND shrtckn_term_code = s1.shrtckg_term_code AND shrtckn_seq_no = s1.shrtckg_tckn_seq_no
WHERE
	1=1
	AND s1.shrtckg_seq_no = (
		SELECT MAX(s2.shrtckg_seq_no)
		FROM shrtckg s2
		WHERE s1.shrtckg_pidm = s2.shrtckg_pidm AND s1.shrtckg_term_code = s2.shrtckg_term_code AND s1.shrtckg_tckn_seq_no = s2.shrtckg_tckn_seq_no
	)
	AND shrtckg_grde_code_final = 'IC'
	AND shrtckn_pidm || shrtckn_term_code || shrtckn_crn NOT IN (
		SELECT shrmrks_pidm || shrmrks_term_code || shrmrks_crn
		FROM shrmrks
		WHERE shrmrks_percentage IS NULL
	)
	
ORDER BY 

	shrtckn_term_code, ssbsect_subj_code || ssbsect_crse_numb
;