SELECT 
	spriden_id,
	s1.sfrensp_pidm, 
	s1.sfrensp_key_seqno,
	s1.sfrensp_term_code, 
	s1.sfrensp_ests_code, 
	s2.sfrensp_pidm,
	s2.sfrensp_key_seqno,
	s2.sfrensp_term_code, 
	s2.sfrensp_ests_code,
	t1.sorlcur_coll_code,
	t1.sorlcur_camp_code,
	t1.sorlcur_levl_code,
	t1.sorlcur_program
FROM 
	sfrensp s1
	JOIN sfrensp s2 ON s1.sfrensp_pidm = s2.sfrensp_pidm AND s1.sfrensp_key_seqno = s2.sfrensp_key_seqno
	JOIN spriden ON s1.sfrensp_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur t1 ON s1.sfrensp_pidm = t1.sorlcur_pidm 
		AND s1.sfrensp_key_seqno = t1.sorlcur_key_seqno 
		AND t1.sorlcur_lmod_code = 'LEARNER' AND t1.sorlcur_cact_code = 'ACTIVE' AND t1.sorlcur_current_cde = 'Y'
WHERE
	1=1
	AND s1.sfrensp_ests_code = 'WD' 
	AND s1.sfrensp_term_code < s2.sfrensp_term_code
	AND t1.sorlcur_term_code = (
		SELECT MAX(t2.sorlcur_term_code)
		FROM sorlcur t2
		WHERE t1.sorlcur_pidm = t2.sorlcur_pidm AND t1.sorlcur_key_seqno = t2.sorlcur_key_seqno 
			AND t2.sorlcur_lmod_code = 'LEARNER' AND t2.sorlcur_cact_code = 'ACTIVE' AND t2.sorlcur_current_cde = 'Y'
	)
ORDER BY
	s1.sfrensp_pidm
;