/*
 * 
 * This query identifies students who have ATWD recorded on their curricula record, but where
 * not all of the Banner Terms indicated have the AT status
 * 
 */


SELECT 
	a1.sorlcur_pidm, 
	a1.sorlcur_leav_code,
	a1.sorlcur_leav_from_date,
	a1.sorlcur_leav_to_date
FROM 
	sorlcur a1
	LEFT JOIN
WHERE
	1=1
	
	-- Curricula Record Criteria
	AND a1.sorlcur_cact_code = 'ACTIVE'
	AND a1.sorlcur_current_cde = 'Y'
	AND a1.sorlcur_lmod_code = 'LEARNER'
	AND a1.sorlcur_term_code = (
	
		SELECT MAX(a2.sorlcur_term_code)
		FROM sorlcur a2
		WHERE 
			1=1
			AND a1.sorlcur_pidm = a2.sorlcur_pidm
			AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno
			AND a2.sorlcur_cact_code = 'ACTIVE'
			AND a2.sorlcur_current_cde = 'Y'
			AND a2.sorlcur_lmod_code = 'LEARNER'
	
	)
	
	-- Limit to approved temporary withdrawal
	AND a1.sorlcur_leav_code = 'A'
	AND a1.sorlcur_leav_to_date >= '31-DEC-2020'
	
	
;