/**
 * Identify students with inconsistent enrolment and module statuses
 */

SELECT 
	spriden_id, sobptrm_end_date, sfrstcr.*
FROM 
	sfrstcr
	JOIN spriden ON sfrstcr_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sobptrm ON sfrstcr_term_code = sobptrm_term_code AND sobptrm_ptrm_code = sfrstcr_ptrm_code
WHERE
	1=1
	AND sfrstcr_rsts_code NOT IN ('UT','DD')
	--AND sfrstcr_term_code = '202101'
	AND sobptrm_end_date > '01-JAN-2021'
	AND sfrstcr_pidm IN 
		(SELECT sfbetrm_pidm FROM sfbetrm WHERE sfbetrm_ests_code = 'UT' AND sfbetrm_term_code = '202101')
ORDER BY 
	spriden_id
;
