/*

All UMP programmes

*/


SELECT DISTINCT
	sobcurr_degc_code,
	sobcurr_program,
	smrprle_program_desc
FROM
	sobcurr_add a1
	JOIN smrprle ON sobcurr_program = smrprle_program
WHERE
    1=1
    AND ump_1 = 'Y'
    AND valstatus_1 = 'CA'
    AND (sobcurr_degc_code LIKE 'BAH%' OR sobcurr_degc_code LIKE 'BSCH%')
;