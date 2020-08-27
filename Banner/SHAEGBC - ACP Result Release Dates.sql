SELECT
	ssbsect_crn,
	ssbsect_subj_code,
	ssbsect_crse_numb,
	ssbsect_camp_code,
	ssbsect_term_code,
	to_char(ssbssec_final_grde_pub_date, 'DD-MON-YYYY') AS "Original Release Date",
	to_char(ssbsect_reas_score_open_date, 'DD-MON-YYYY') AS "Date Suppressed For Resits",
	--to_char(ssbsect_reas_score_ctof_date, 'DD-MON-YYYY'),
	to_char(ssbssec_reas_grde_pub_date, 'DD-MON-YYYY') AS "Resit Result Release"
FROM 
	ssbsect
	JOIN ssbssec ON ssbsect_term_code = ssbssec_term_code AND ssbsect_crn = ssbssec_crn
WHERE
	1=1
	AND ssbsect_camp_code NOT IN ('OBO','OBS','DL')
	AND ssbsect_term_code IN ('201909','202001','202006')
ORDER BY 
	ssbsect_camp_code,
	ssbsect_subj_code,
	ssbsect_crse_numb

;