SELECT DISTINCT
	UPPER(prog_lead_1),
	spriden_last_name,
	spriden_first_name
	
FROM
	sobcurr_add
	LEFT JOIN spriden ON UPPER(prog_lead_1) = spriden_id
	
WHERE
	1=1
	
	AND ump_1 = 'Y'
	AND valstatus_1 IN ('CA', 'CL')
;