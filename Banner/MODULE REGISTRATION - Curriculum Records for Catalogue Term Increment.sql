SELECT
	sorlcur_seqno, sorlcur_lmod_code, sorlcur_term_code, sorlcur_term_code_ctlg, s1.*
FROM 
	sgrsatt s1
	JOIN sorlcur c1 ON s1.sgrsatt_pidm = c1.sorlcur_pidm AND s1.sgrsatt_stsp_key_sequence = c1.sorlcur_key_seqno
WHERE 
	1=1
	-- Pull through all students who have an X2 attribute starting on the given term
	AND s1.sgrsatt_term_code_eff = :term_code
	AND s1.sgrsatt_atts_code = :attribute
	-- Exclude students who have already progressed onto X2 in an earlier term
	AND s1.sgrsatt_pidm || s1.sgrsatt_stsp_key_sequence || s1.sgrsatt_atts_code NOT IN (
		SELECT s2.sgrsatt_pidm || s2.sgrsatt_stsp_key_sequence || s2.sgrsatt_atts_code
		FROM sgrsatt s2
		WHERE s2.sgrsatt_term_code_eff < :term_code AND s1.sgrsatt_atts_code = :attribute
	)
	-- Return details of the maximum sorlcur record for the study path
	AND c1.sorlcur_lmod_code = 'LEARNER'
	AND c1.sorlcur_cact_code = 'ACTIVE'
	AND c1.sorlcur_current_cde = 'Y'
	AND c1.sorlcur_term_code_end IS NULL
	AND c1.sorlcur_term_code = (
		SELECT MAX(c2.sorlcur_term_code)
		FROM sorlcur c2
		WHERE
			1=1
			AND c1.sorlcur_pidm = c2.sorlcur_pidm
			AND c1.sorlcur_key_seqno = c2.sorlcur_key_seqno
			AND c2.sorlcur_lmod_code = 'LEARNER'
			AND c2.sorlcur_cact_code = 'ACTIVE'
			AND c2.sorlcur_current_cde = 'Y'
			AND c2.sorlcur_term_code_end IS NULL
	)
;

SELECT * FROM sorlcur