SELECT
	spriden_id, t1.sorlcur_styp_code, sgrsatt.*
FROM 
	sgrsatt
	JOIN spriden ON sgrsatt_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur t1 ON sgrsatt_pidm = t1.sorlcur_pidm AND sgrsatt_stsp_key_sequence = t1.sorlcur_key_seqno
WHERE
	1=1
	AND sgrsatt_term_code_eff = '201909'
	AND sgrsatt_atts_code = 'X1'
	AND sgrsatt_pidm || sgrsatt_stsp_key_sequence NOT IN (
		SELECT sgrsatt_pidm || sgrsatt_stsp_key_sequence
		FROM sgrsatt 
		WHERE 
			1=1
			AND sgrsatt_term_code_eff >= '202009' 
			AND sgrsatt_atts_code IN ('X2', 'SW')
	)
	AND sgrsatt_pidm IN (
		SELECT sgbstdn_pidm
		FROM sgbstdn s1
		WHERE 
			1=1
			AND s1.sgbstdn_term_code_eff = (SELECT MAX (s2.sgbstdn_term_code_eff) FROM sgbstdn s2 WHERE s1.sgbstdn_pidm = s2.sgbstdn_pidm)
			AND s1.sgbstdn_stst_code = 'AS'
	)
	AND t1.sorlcur_term_code = (SELECT MAX(t2.sorlcur_term_code) FROM sorlcur t2 WHERE t1.sorlcur_pidm = t2.sorlcur_pidm AND t1.sorlcur_key_seqno = t2.sorlcur_key_seqno AND t2.sorlcur_cact_code = 'ACTIVE' AND t2.sorlcur_current_cde = 'Y' AND t2. sorlcur_lmod_code = 'LEARNER')
	AND t1.sorlcur_cact_code = 'ACTIVE'
	AND t1.sorlcur_current_cde = 'Y'
	AND t1.sorlcur_lmod_code = 'LEARNER'
	AND t1.sorlcur_styp_code = 'F'
;


