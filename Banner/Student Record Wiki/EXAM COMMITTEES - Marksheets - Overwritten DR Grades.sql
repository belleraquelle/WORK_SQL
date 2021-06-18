/*
 * Returns a list of modules in academic history where a DR grade has previously been recorded
 * but where the latest grade is not a DR
 */

SELECT 
	spriden_id, 
	shrtckn_crn, 
	s1.*
FROM 
	shrtckg s1
	JOIN spriden ON s1.shrtckg_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN shrtckn ON s1.shrtckg_pidm = shrtckn_pidm AND s1.shrtckg_term_code = shrtckn_term_code AND s1.shrtckg_tckn_seq_no = shrtckn_seq_no
WHERE 
	-- Return the latest grade for each module
	s1.shrtckg_seq_no = (
		SELECT MAX(s2.shrtckg_seq_no) 
		FROM shrtckg s2 
		WHERE s1.shrtckg_pidm = s2.shrtckg_pidm 
			AND s1.shrtckg_term_code = s2.shrtckg_term_code 
			AND s1.shrtckg_tckn_seq_no = s2.shrtckg_tckn_seq_no
		)
	-- Limit to those where the latest grade isn't a DR
	AND s1.shrtckg_grde_code_final != 'DR'
	-- Optional limit by term
	-- AND s1.shrtckg_term_code >= '202009'
	-- Limit to rows where there was a DR grade recorded against the module previously
	AND s1.shrtckg_pidm || s1.shrtckg_term_code || s1.shrtckg_tckn_seq_no IN (
		SELECT shrtckg_pidm || shrtckg_term_code || shrtckg_tckn_seq_no
		FROM shrtckg
		WHERE shrtckg_grde_code_final = 'DR'
	)
ORDER BY 
	s1.shrtckg_term_code, 
	spriden_id, 
	shrtckn_crn
	;