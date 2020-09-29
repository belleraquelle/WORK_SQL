/*
 * This query can be used to identify students who are 'part way' through enrolment for a given Banner Term
 */

SELECT 
	szrenrl_student_id AS "Student_ID",
	szrenrl_first_name AS "First_Name",
	szrenrl_last_name AS "Last_Name",
	sorlcur1.sorlcur_term_code_admit AS "Admit_Term",
	sorlcur1.sorlcur_program AS "Programme_Code",
	sorlcur1.sorlcur_end_date AS "Expected_Completion_Date",
	szrenrl_term_code AS "Enrolment_Term",
	szrenrl_academic_enrol_status AS "Academic_Enrolment_Status",
	szrenrl_financial_enrol_status AS "Financial_Enrolment_Status",
	sfbetrm_ests_code AS "Overall_Enrolment_Status"
FROM 
	szrenrl
	LEFT JOIN sfbetrm ON szrenrl_pidm = sfbetrm_pidm AND sfbetrm_ests_code = 'EL'
	JOIN sorlcur sorlcur1 ON szrenrl_pidm = sorlcur1.sorlcur_pidm
WHERE
	1=1
	
	-- Pick current sorlcur record for study path
	AND sorlcur1.sorlcur_lmod_code = 'LEARNER'
	AND sorlcur1.sorlcur_cact_code = 'ACTIVE'
	AND sorlcur1.sorlcur_current_cde = 'Y'
	AND sorlcur1.sorlcur_end_date > sysdate
	AND sorlcur1.sorlcur_term_code = (
	
		SELECT MAX(sorlcur2.sorlcur_term_code)
		FROM sorlcur sorlcur2
		WHERE
			1=1
			AND sorlcur1.sorlcur_pidm = sorlcur2.sorlcur_pidm
			AND sorlcur1.sorlcur_key_seqno = sorlcur2.sorlcur_key_seqno
			AND sorlcur2.sorlcur_lmod_code = 'LEARNER'
			AND sorlcur2.sorlcur_cact_code = 'ACTIVE'
			AND sorlcur2.sorlcur_current_cde = 'Y'
	
	)
	
	AND szrenrl_academic_enrol_status = 'CO'
	AND (szrenrl_financial_enrol_status != 'CO' OR szrenrl_financial_enrol_status IS NULL)
	AND szrenrl_term_code = '202009'
	AND sfbetrm_term_code = '202009'	
;