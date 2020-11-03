/*
*
* Check the consistency of learner and study path enrolment statuses within a given term
*
*/

SELECT 
	spriden_id AS "Student_Number",
	sfbetrm_pidm AS "PIDM",
	sfrensp_key_seqno AS "Study_Path",
	sorlcur_program AS "Programme",
	sfbetrm_ests_code AS "Learner_Enrolment_Status",
	sfrensp_ests_code AS "Study_Path_Enrolment_Status"
FROM 
	sfbetrm
	JOIN sfrensp ON sfbetrm_pidm = sfrensp_pidm AND sfbetrm_term_code = sfrensp_term_code
	JOIN sorlcur a1 ON sfrensp_pidm = a1.sorlcur_pidm AND sfrensp_key_seqno = a1.sorlcur_key_seqno
	JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE 
	1=1
	
	-- Term to check enrolment codes
	AND sfbetrm_term_code = '202009'
	
	-- Limit to records where the study path and learner enrolment codes don't match
	AND sfbetrm_ests_code != sfrensp_ests_code
	
	-- Pick out max curricula record for the study path
	AND a1.sorlcur_lmod_code = 'LEARNER'
	AND a1.sorlcur_cact_code = 'ACTIVE'
	AND a1.sorlcur_current_cde = 'Y'
	AND a1.sorlcur_term_code = ( 
		
		SELECT MAX(a2.sorlcur_term_code)
		FROM sorlcur a2
		WHERE
			1=1
			AND a1.sorlcur_pidm = a2.sorlcur_pidm
			AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno
			AND a2.sorlcur_lmod_code = 'LEARNER'
			AND a2.sorlcur_cact_code = 'ACTIVE'
			AND a2.sorlcur_current_cde = 'Y'
	
		)
	
	-- Exclude VSMS programmes
	AND a1.sorlcur_program NOT LIKE ('%-V')
		
ORDER BY 
	a1.sorlcur_program
	
;



SELECT * FROM sfbetrm;