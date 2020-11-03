/* 
 * This query identifies records where a student has an EL status against a term that is beyond their completion date
 * 
 */

SELECT
	spriden_id AS "Student_Number",
	a1.sorlcur_pidm AS "PIDM",
	a1.sorlcur_program AS "Program",
	a1.sorlcur_key_seqno AS "Study_Path",
	a1.sorlcur_end_date AS "Expected_Completion_Date",
	stvterm_code AS "Expected_End_Term",
	sfrensp_term_code AS "SP_Enrolment_Term",
	sfrensp_ests_code AS "SP_Enrolment_Status",
	sfbetrm_term_code AS "Learner_Enrolment_Term",
	sfbetrm_ests_code AS "Learner_Enrolment_Status"
--	CASE 
--		WHEN a1.sorlcur_pidm || a1.sorlcur_key_seqno IN ( 
--		
--			SELECT sfrstcr_pidm || sfrstcr_stsp_key_sequence
--			FROM sfrstcr
--			WHERE sfrstcr_term_code = sfrensp_term_code AND sfrstcr_rsts_code = 'FE'
--		
--		) THEN 'Y'
--	END AS "Fee_Module_Registered_In_Term",
	
FROM
	sorlcur a1 
	JOIN stvterm ON a1.sorlcur_end_date BETWEEN stvterm_start_date AND stvterm_end_date
	JOIN sfrensp ON a1.sorlcur_pidm = sfrensp_pidm AND a1.sorlcur_key_seqno = sfrensp_key_seqno
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sfbetrm ON a1.sorlcur_pidm = sfbetrm_pidm AND sfrensp_term_code = sfbetrm_term_code
	
WHERE 

	1=1
	
	-- SORLCUR requirements  
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
	
	-- Identify records where there is a status recorded against the study path in a term beyond the student's completion term
	AND sfrensp_term_code > stvterm_code
	AND sfrensp_ests_code = 'EN'
	--AND sfbetrm_ests_code != 'EL'
	
	-- Exclude VSMS programmes
	AND a1.sorlcur_program NOT LIKE ('%-V')

ORDER BY 
	sfrensp_term_code
;