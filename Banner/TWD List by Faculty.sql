SELECT 
	spriden_id,
	spriden_last_name,
	spriden_first_name,
	sfrensp_pidm,
	sfrensp_term_code,
	sfrensp_key_seqno,
	sfrensp_ests_code,
	a1.sorlcur_program,
	a1.sorlcur_coll_code,
	CASE 
		WHEN sfrensp_ests_code = 'AT' THEN
		(
		SELECT z2.sorlcur_leav_to_date
		FROM sorlcur z2
		WHERE 
			a1.sorlcur_pidm = z2.sorlcur_pidm 
			AND a1.sorlcur_key_seqno = z2.sorlcur_key_seqno 
			AND z2.sorlcur_current_cde = 'Y'
			AND z2.sorlcur_lmod_code = 'LEARNER'
			AND z2.sorlcur_cact_code = 'ACTIVE'
			AND z2.sorlcur_term_code = (
				SELECT MAX (z3.sorlcur_term_code) 
				FROM sorlcur z3 
				WHERE 
					z2.sorlcur_pidm = z3.sorlcur_pidm
					AND z2.sorlcur_key_seqno = z3.sorlcur_key_seqno
					AND z3.sorlcur_leav_to_date IS NOT NULL
					AND z3.sorlcur_current_cde = 'Y'
					AND z3.sorlcur_lmod_code = 'LEARNER'
					AND z3.sorlcur_cact_code = 'ACTIVE'
			)
		)
	END AS "Last_Day_of_ATWD"
FROM 
	sfrensp
	JOIN sorlcur a1 ON sfrensp_pidm = a1.sorlcur_pidm AND sfrensp_key_seqno = a1.sorlcur_key_seqno
	JOIN spriden ON sfrensp_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	AND sfrensp_term_code = '202009'
	AND sfrensp_ests_code IN ('AT', 'UT')
	AND a1.sorlcur_term_code = (
        SELECT MAX(a2.sorlcur_term_code) 
        FROM sorlcur a2 
        WHERE a1.sorlcur_pidm = a2.sorlcur_pidm AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno AND a1.sorlcur_lmod_code = 'LEARNER'
        )
    AND a1.sorlcur_lmod_code = 'LEARNER'
    AND a1.sorlcur_cact_code = 'ACTIVE'
    AND a1.sorlcur_current_cde = 'Y'
	AND a1.sorlcur_coll_code LIKE 'B%'
	AND a1.sorlcur_levl_code != 'RD'
ORDER BY 
	a1.sorlcur_program
;


SELECT * FROM sorlcur;