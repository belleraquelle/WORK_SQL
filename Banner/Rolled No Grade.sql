SELECT DISTINCT
	sfrstcr_term_code, 
	sfrstcr_crn
FROM 
	sfrstcr
WHERE
	1=1
	AND sfrstcr_grde_code IS NULL 
	AND sfrstcr_rsts_code IN ('RE','RW','RC')
	AND sfrstcr_term_code || sfrstcr_crn IN ( 
	
		SELECT shrtckn_term_code || shrtckn_crn
		FROM shrtckn
		WHERE
			sfrstcr_pidm = shrtckn_pidm
	
	)
ORDER BY
	sfrstcr_term_code
	
;


SELECT * FROM sfrstcr