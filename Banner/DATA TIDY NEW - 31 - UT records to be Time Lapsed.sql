/*
 * UT records to be time lapsed
 * 
 * This query returns students who have a continuous UT status period that started before the specified date. 
 * It can be used to identify the groups of students who need to be Time Lapsed. 
 * The term for the withdrawal code should be the term BEFORE the Min_UT_Term, with an end date recorded as the last date of that term.
 * For example, a student with a Min_UT_Term of 201909, would be recorded as withdrawn in 201906 with a leaving date of 31/08/2019.
 * 
 */

SELECT 
	spriden_id AS "Student_Number",
	a1.sfbetrm_pidm AS "Student_PIDM",
	sfrensp_key_seqno AS "Study_Path", 
	s1.sorlcur_program AS "Programme",
	s1.sorlcur_end_date AS "Learner_End_Date",
	a1.sfbetrm_term_code AS "Last_Enrolment_Term",
	a1.sfbetrm_ests_code AS "Last_Enrolment_Status",
	b1.sfbetrm_term_code AS "Min_UT_Term",
	c1.sfbetrm_term_code AS "Max_UT_Term"
		
--	sfbetrm_term_code AS "Withdrawal_Term", 
--	sfbetrm_ests_code AS "Learner_Enrolment_Status", 
--	sfrensp_ests_code AS "Study_Path_Enrolment_Status",
--	sfbetrm_rgre_code AS "Withdrawal_Reason"
FROM 
	spriden 
	
	-- Last enrolment record
	JOIN sfbetrm a1 ON a1.sfbetrm_pidm = spriden_pidm AND a1.sfbetrm_term_code = (
		SELECT MAX(a2.sfbetrm_term_code)
		FROM sfbetrm a2
		WHERE a1.sfbetrm_pidm = a2.sfbetrm_pidm
	)
	
	-- Start term for current UT period
	JOIN sfbetrm b1 ON spriden_pidm = b1.sfbetrm_pidm AND b1.sfbetrm_term_code = (
		SELECT MIN(b2.sfbetrm_term_code)
		FROM sfbetrm b2
		WHERE b1.sfbetrm_pidm = b2.sfbetrm_pidm AND b2.sfbetrm_ests_code = 'UT'
			AND b1.sfbetrm_term_code > (SELECT MAX(b3.sfbetrm_term_code) FROM sfbetrm b3 WHERE b3.sfbetrm_pidm = b1.sfbetrm_pidm AND b3.sfbetrm_ests_code IN ('EN','AT'))
	)
	
	-- End term for current UT period
	JOIN sfbetrm c1 ON spriden_pidm = c1.sfbetrm_pidm AND c1.sfbetrm_term_code = (
		SELECT MAX(c2.sfbetrm_term_code)
		FROM sfbetrm c2
		WHERE c1.sfbetrm_pidm = c2.sfbetrm_pidm AND c2.sfbetrm_ests_code = 'UT'
			AND c1.sfbetrm_term_code > (SELECT MAX(c3.sfbetrm_term_code) FROM sfbetrm c3 WHERE c3.sfbetrm_pidm = c1.sfbetrm_pidm AND c3.sfbetrm_ests_code IN ('EN','AT'))
	)
	JOIN sfrensp ON a1.sfbetrm_pidm = sfrensp_pidm AND a1.sfbetrm_term_code = sfrensp_term_code
	JOIN sorlcur s1 ON sfrensp_pidm = s1.sorlcur_pidm AND sfrensp_key_seqno = s1.sorlcur_key_seqno
	
WHERE
	1=1
	
	AND spriden_change_ind IS NULL
	
	-- Limit to students who first went on UT before the specified term
	AND b1.sfbetrm_term_code <= '202001'
	
	-- Exclude students with a 'final' enrolment status as their most recent status
	AND a1.sfbetrm_ests_code NOT IN ('WD', 'EN', 'AT', 'XF')
	
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
	
ORDER BY 
	b1.sfbetrm_term_code, 
	s1.sorlcur_program
;