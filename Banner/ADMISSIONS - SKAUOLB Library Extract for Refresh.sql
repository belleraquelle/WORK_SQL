SELECT DISTINCT
	substr(skruolb_marvin_string, 2, 4) AS "UCAS_Code",  
	skruolb_avail_system_wide,
	substr(skruolb_marvin_string,1,10)||'22SEP' AS "skrulb_marvin_string",
	substr(skruolb_offer_code,1,16)||'SEP22' AS "skruolb_offer_code",
	skruolb_decision_r,
	skruolb_decision_c,
	skruolb_decision_u,
	skruolb_decision_w,
	substr(skruolb_descr,1,15)||'SEP22' AS "skruolb_descr",
	sysdate AS "skruolb_activity_date",
	'Upload' AS "skruolb_user"
FROM 
	skruolb
WHERE
	1=1
	AND skruolb_offer_code LIKE 'CC%SEP21' -- Pick out last years codes
	
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
	
	--Exclude entries that already exist
	AND substr(skruolb_marvin_string,1,10)||'22SEP' NOT IN (
		SELECT skruolb_marvin_string
		FROM skruolb
	)
;