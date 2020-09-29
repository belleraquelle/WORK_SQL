/*
 * This query can be used to identify students who are 'part way' through enrolment for a given Banner Term
 */

SELECT 
	szrenrl_student_id,
	szrenrl_first_name,
	szrenrl_last_name,
	szrenrl_term_code,
	szrenrl_academic_enrol_status,
	szrenrl_financial_enrol_status,
	sfbetrm_ests_code
FROM 
	szrenrl
	LEFT JOIN sfbetrm ON szrenrl_pidm = sfbetrm_pidm
WHERE
	1=1
	AND szrenrl_academic_enrol_status = 'CO'
	AND (szrenrl_financial_enrol_status != 'CO' OR szrenrl_financial_enrol_status IS NULL)
	AND szrenrl_term_code = '202009'
	AND sfbetrm_term_code = '202009'
	AND (sfbetrm_ests_code = 'EL' OR sfbetrm_ests_code IS NULL)
	
;