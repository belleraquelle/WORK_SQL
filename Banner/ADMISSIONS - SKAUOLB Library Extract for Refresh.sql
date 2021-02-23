SELECT DISTINCT
	substr(skruolb_marvin_string, 2, 4) AS "UCAS_Code", skruolb.*
FROM 
	skruolb
WHERE
	1=1
	AND (skruolb_offer_code LIKE 'CC%SEP21' OR skruolb_offer_code LIKE 'CC%JAN22') -- Pick out last years codes
	
	-- Limit to UCAS codes that are attached to Banner course codes that are still open to recruitment
	AND substr(skruolb_marvin_string, 2, 4) IN (
		SELECT 
			skrutop_ssdt_code_crse--, sobcurr_add.*
		FROM 
			skrutop
			JOIN sobcurr_add ON skrutop_program = sobcurr_program AND nvl(skrutop_ssdt_code_camp, 'OBO') = sobcurr_camp_code
		WHERE 
			1=1
			AND valstatus_1 IN ('CA', 'FA', 'FC')
	)
	
;