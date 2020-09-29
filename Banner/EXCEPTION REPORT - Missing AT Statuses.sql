/*
 * 
 * This query identifies students who have ATWD recorded on their curricula record, but where
 * not all of the Banner Terms indicated have the AT status
 * 
 */


SELECT 
	spriden_id,
	a1.sorlcur_pidm, 
	a1.sorlcur_program,
	a1.sorlcur_leav_code,
	a1.sorlcur_leav_from_date,
	a1.sorlcur_leav_to_date,
	sfrensp_ests_code,
	sfbetrm_ests_code
FROM 
	sorlcur a1
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
	LEFT JOIN sfrensp ON a1.sorlcur_pidm = sfrensp_pidm AND a1.sorlcur_key_seqno = sfrensp_key_seqno AND sfrensp_term_code = :term_code
	LEFT JOIN sfbetrm ON a1.sorlcur_pidm = sfbetrm_pidm AND sfbetrm_term_code = :term_code
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
	AND a1.sorlcur_leav_from_date <= :TWD_End_Date_Greater_Than_Or_Equal_To
	AND a1.sorlcur_leav_to_date >= :TWD_End_Date_Greater_Than_Or_Equal_To
	
	
	AND ((sfrensp_ests_code != 'AT' OR sfrensp_ests_code IS NULL)
	OR (sfbetrm_ests_code != 'AT' OR sfbetrm_ests_code IS NULL))

	
	
;