/*
 * This query extracts all of the students with a leaving reason of Time Lapsed
 * and who do not have an award for their study path. 
 * 
 * This can be further refined by focussing on students based on their end dates.
 * 
 * Can be used to work through the Time Lapsed students and check any that would be
 * eligible for an exit award of some kind. 
 */

SELECT 
	spriden_id AS "Student_Number",
	sfbetrm_pidm AS "Student_PIDM",
	sfrensp_key_seqno AS "Study_Path", 
	s1.sorlcur_program AS "Programme",
	s1.sorlcur_end_date AS "Learner_End_Date",
	shrdgmr_degs_code AS "Award_Status",
	sfbetrm_term_code AS "Withdrawal_Term", 
	sfbetrm_ests_code AS "Learner_Enrolment_Status", 
	sfrensp_ests_code AS "Study_Path_Enrolment_Status",
	sfbetrm_rgre_code AS "Withdrawal_Reason"
FROM 
	sfbetrm
	JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sfrensp ON sfbetrm_pidm = sfrensp_pidm AND sfbetrm_term_code = sfrensp_term_code
	JOIN sorlcur s1 ON sfrensp_pidm = s1.sorlcur_pidm AND sfrensp_key_seqno = s1.sorlcur_key_seqno
	LEFT JOIN shrdgmr ON s1.sorlcur_pidm = shrdgmr_pidm AND s1.sorlcur_key_seqno = shrdgmr_stsp_key_sequence
WHERE
	1=1
	AND sfbetrm_ests_code = 'WD'
	AND sfbetrm_rgre_code = 'TL'
	
	-- SORLCUR paramaters
	AND s1.sorlcur_lmod_code = 'LEARNER'
	AND s1.sorlcur_cact_code = 'ACTIVE'
	AND s1.sorlcur_current_cde = 'Y'
	AND s1.sorlcur_term_code = (
		SELECT MAX(s2.sorlcur_term_code)
		FROM sorlcur s2
		WHERE s1.sorlcur_pidm = s2.sorlcur_pidm AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno AND s2.sorlcur_lmod_code = 'LEARNER' 
			AND s2.sorlcur_cact_code = 'ACTIVE' AND s2.sorlcur_current_cde = 'Y'
	) 
	
	-- Exclude students with an award on the study path
	AND (shrdgmr_degs_code != 'AW' OR shrdgmr_degs_code IS NULL)
ORDER BY 
	sfbetrm_ests_date
;