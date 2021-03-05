/*
 * 
 * This query identifies possible disrepencies between student enrolment status and module registration statuses. 
 * 
 * For exmaple, students who are ATWD for the semester in which a module runs but where the module is still registered. 
 */

SELECT 
	spriden_id AS "Student_Number",
	sfrstcr_crn AS "CRN",
	sfrstcr_term_code AS "Module_attached_to",
	sfrstcr_ptrm_code AS "Module_Part_of_Term",
	sobptrm_start_date AS "Module_Start_Date",
	sobptrm_end_date AS "Module_End_Date",
	sfrstcr_rsts_code AS "Module_Registration_Status",
	sfbetrm_term_code AS "Enrolment_Term",
	sfbetrm_ests_code AS "Enrolment_Status",
	sfbetrm_ests_date AS "Enrolment_Status_Date"
FROM 
	sfbetrm 
	JOIN sfrstcr ON sfbetrm_pidm = sfrstcr_pidm
	JOIN sobptrm ON sfrstcr_ptrm_code = sobptrm_ptrm_code AND sobptrm_term_code = sfrstcr_term_code
	JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	-- Enrolment terms module runs for
	
	AND sfbetrm_term_code IN (
		
		SELECT 
			stvterm_code 
		FROM 
			stvterm
		WHERE
			1=1
			AND ((stvterm_start_date BETWEEN sobptrm_start_date + 14 AND sobptrm_end_date) OR (stvterm_end_date BETWEEN sobptrm_start_date + 14 AND sobptrm_end_date) OR (stvterm_start_date + 14 < sobptrm_start_date AND stvterm_end_date > sobptrm_end_date))
	
	)

	-- Identify records with mismatching enrolment / module registration statuses	
	AND (
		(sfbetrm_ests_code IN ('EL','EN') AND sfrstcr_rsts_code IN ('AT','UT','WD'))
		OR (sfbetrm_ests_code IN ('AT','UT', 'WD') AND sfrstcr_rsts_code IN ('RE','RW','RC','FE'))
		)
		
	-- Exclude any rows for modules that run over multiple semesters where the statuses match on at least one row e.g. AT against both enrolment and module registration statuses
	AND sfrstcr_pidm || sfrstcr_term_code || sfrstcr_crn NOT IN (
		SELECT 
			sfrstcr_pidm || sfrstcr_term_code || sfrstcr_crn
		FROM 
			sfbetrm 
			JOIN sfrstcr ON sfbetrm_pidm = sfrstcr_pidm
			JOIN sobptrm ON sfrstcr_ptrm_code = sobptrm_ptrm_code AND sobptrm_term_code = sfrstcr_term_code
		WHERE
			1=1
			-- Enrolment terms module runs for
			AND sfbetrm_term_code IN (
				SELECT 
					stvterm_code 
				FROM
					stvterm
				WHERE
					1=1
					AND ((stvterm_start_date BETWEEN sobptrm_start_date + 14 AND sobptrm_end_date) OR (stvterm_end_date BETWEEN sobptrm_start_date + 14 AND sobptrm_end_date) OR (stvterm_start_date + 14 < sobptrm_start_date AND stvterm_end_date > sobptrm_end_date))
			)
			
			AND sfrstcr_rsts_code = sfbetrm_ests_code
	
	)
	
	-- Limit to rows where the enrolment status date is LESS than the module end date
	AND sfbetrm_ests_date < sobptrm_end_date
	
	
ORDER BY 
	sfbetrm_pidm, 
	sfrstcr_crn,
	sfbetrm_term_code
;