SELECT DISTINCT
	UPPER(subj_coord_1),
	spriden_last_name,
	spriden_first_name,
	sobcurr_program,
	smrprle_program_desc
	
FROM
	sobcurr_add
	LEFT JOIN spriden ON UPPER(subj_coord_1) = spriden_id
	JOIN smrprle ON smrprle_program = sobcurr_program
	
WHERE
	1=1
	
	AND ump_1 = 'Y'
	AND valstatus_1 IN ('CA', 'CL')
;

SELECT * FROM sobcurr_add;

SELECT * FROM SMBPROG;