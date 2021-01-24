/*
 * Query returns any components on modules that ended between the date range where the mark is greater than zero
 * yet they have a 'Not Attempted' comment. 
 * In instances like this, we would typically need to take the comment off, unless it has been entered to
 * suppress the resit for conduct reasons.
 */

SELECT
--	shrmrks_pidm || shrmrks_term_code || shrmrks_crn || shrmrks_gcom_id
	shrmrks_pidm,
	spriden_id,
	spriden_last_name || ',' || spriden_first_name,
	shrmrks_term_code,
	shrmrks_crn, 
	shrtckn_subj_code || shrtckn_crse_numb, 
	shrtckn_ptrm_end_date,
	shrmrks_gcom_id,
	shrmrks_percentage,
	shrmrks_grde_code,
	shrmrks_comments
FROM 
	shrmrks
	JOIN shrtckn ON shrmrks_pidm = shrtckn_pidm AND shrmrks_term_code = shrtckn_term_code AND shrmrks_crn = shrtckn_crn
	JOIN spriden ON shrmrks_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	AND shrmrks_comments = 'Not Attempted'
	AND shrtckn_ptrm_end_date BETWEEN '01-OCT-2020' AND '31-DEC-2020'
	AND shrmrks_percentage > 0
	;