/*
*  Checks for two or more fails on the same module in Academic History.
*/

SELECT DISTINCT
	b1.shrtckn_pidm,
	spriden_id, 
	spriden_last_name || ', ' || spriden_first_name,
	s1.sorlcur_program,
	b1.shrtckn_subj_code,
	b1.shrtckn_crse_numb
FROM 
	shrtckg a1
	JOIN shrtckn b1 ON a1.shrtckg_pidm = b1.shrtckn_pidm AND a1.shrtckg_tckn_seq_no = b1.shrtckn_seq_no AND a1.shrtckg_term_code = b1.shrtckn_term_code
	JOIN shrtckn c1 ON b1.shrtckn_pidm = c1.shrtckn_pidm AND b1.shrtckn_subj_code = c1.shrtckn_subj_code AND b1.shrtckn_crse_numb = c1.shrtckn_crse_numb 
		AND b1.shrtckn_crn != c1.shrtckn_crn
	JOIN shrtckg d1 ON d1.shrtckg_pidm = c1.shrtckn_pidm AND d1.shrtckg_tckn_seq_no = c1.shrtckn_seq_no AND d1.shrtckg_term_code = c1.shrtckn_term_code
	JOIN spriden ON a1.shrtckg_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur s1 ON b1.shrtckn_pidm = s1.sorlcur_pidm AND b1.shrtckn_stsp_key_sequence = s1.sorlcur_key_seqno
WHERE
	1=1
	AND a1.shrtckg_seq_no = (
		SELECT MAX(a2.shrtckg_seq_no) 
		FROM shrtckg a2 
		WHERE a1.shrtckg_pidm = a2.shrtckg_pidm AND a1.shrtckg_term_code = a2.shrtckg_term_code AND a1.shrtckg_tckn_seq_no = a2.shrtckg_tckn_seq_no
		)
	AND d1.shrtckg_seq_no = (
		SELECT MAX(d2.shrtckg_seq_no) 
		FROM shrtckg d2 
		WHERE d1.shrtckg_pidm = d2.shrtckg_pidm AND d1.shrtckg_term_code = d2.shrtckg_term_code AND d1.shrtckg_tckn_seq_no = d2.shrtckg_tckn_seq_no
		)
	AND a1.shrtckg_grde_code_final IN ('F','FAIL')
	AND b1.shrtckn_ptrm_end_date BETWEEN :module_end_date_range_start AND :module_end_date_range_end
	AND d1.shrtckg_grde_code_final IN ('F','FAIL')
	AND s1.sorlcur_lmod_code = 'LEARNER' 
	AND s1.sorlcur_cact_code = 'ACTIVE' 
	AND s1.sorlcur_current_cde = 'Y'
	AND s1.sorlcur_term_code = (
		SELECT MAX(s2.sorlcur_term_code)
		FROM sorlcur s2
		WHERE s1.sorlcur_pidm = s2.sorlcur_pidm AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno 
			AND s2.sorlcur_lmod_code = 'LEARNER' AND s2.sorlcur_cact_code = 'ACTIVE' AND s2.sorlcur_current_cde = 'Y'
	)
	
;
