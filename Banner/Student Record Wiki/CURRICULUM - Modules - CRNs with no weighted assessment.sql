SELECT
	shrgcom_term_code,
	shrgcom_crn,
	ssbsect_subj_code, 
	ssbsect_crse_numb,
	SUM(shrgcom_weight)
FROM 
	shrgcom
	JOIN ssbsect ON shrgcom_term_code = ssbsect_term_code AND shrgcom_crn = ssbsect_crn
WHERE
	1=1
HAVING 
	SUM(shrgcom_weight) < 1
GROUP BY
	shrgcom_term_code,
	shrgcom_crn,
	ssbsect_subj_code,
	ssbsect_crse_numb
ORDER BY 
	ssbsect_subj_code,
	shrgcom_term_code
;