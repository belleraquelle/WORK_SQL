SELECT
	spriden_id, s1.*
FROM
	sorlcur s1
	JOIN spriden ON s1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	AND s1.sorlcur_program IN ('CRTFN-UEL1', 'CRTFN-UEL2', 'CRTUG-UEL3', 'CRTUG-UEL4')
	AND s1.sorlcur_lmod_code = 'LEARNER'
	AND s1.sorlcur_term_code = (
		SELECT MAX(s2.sorlcur_term_code)
		FROM sorlcur s2
		WHERE 1=1
			AND s1.sorlcur_pidm = s2.sorlcur_pidm 
			AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno
			AND s2.sorlcur_lmod_code = 'LEARNER'
			AND s2.sorlcur_cact_code = 'ACTIVE'
			AND s2.sorlcur_current_cde = 'Y'
	)
	AND s1.sorlcur_cact_code = 'ACTIVE'
	AND s1.sorlcur_current_cde = 'Y'
	AND s1.sorlcur_end_date BETWEEN '01-MAR-2020' AND '31-MAY-2020'
;