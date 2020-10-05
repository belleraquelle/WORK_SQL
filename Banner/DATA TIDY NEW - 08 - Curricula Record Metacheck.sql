/*
*
* Curricula record master check. This looks for key bits of missing data on the current curricula record for a student.
*
*/


SELECT 
	spriden_id AS "Student_Number", 
	a1.sorlcur_pidm AS "PIDM",
	a1.sorlcur_key_seqno AS "Study_Path",
	a1.sorlcur_program AS "Programme",
	a1.sorlcur_term_code AS "Curricula_Term_Code",
	CASE 
		WHEN a1.sorlcur_start_date IS NULL THEN 'Missing start date'
		WHEN a1.sorlcur_end_date IS NULL THEN 'Missing end date'
		WHEN a1.sorlcur_styp_code IS NULL THEN 'Missing mode of study (Student Type)'
		WHEN a1.sorlcur_curr_rule IS NULL THEN 'Missing curricula rule: re-add curricula using Change Curricula'
		WHEN a1.sorlcur_start_date > a1.sorlcur_end_date THEN 'End date is before start date PANIC'
	END AS "Issue"
	
FROM 
	sorlcur a1
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	
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
		
	-- Exclude VSMS courses
	AND a1.sorlcur_program NOT LIKE '%-V'
	
	-- Exclude pre-Banner records
	AND sorlcur_term_code_admit >= '201909'
		
	-- Checking for missing data
	AND (
	
		a1.sorlcur_start_date IS NULL
		OR a1.sorlcur_end_date IS NULL 
		OR a1.sorlcur_styp_code IS NULL 
		OR a1.sorlcur_curr_rule IS NULL
		OR a1.sorlcur_start_date > a1.sorlcur_end_date
	
	)
	
	
	
;

SELECT * FROM sorlcur;