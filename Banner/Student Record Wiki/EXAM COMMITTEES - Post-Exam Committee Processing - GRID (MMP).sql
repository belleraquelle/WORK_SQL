SELECT
	a1.spriden_id, 
	a1.spriden_last_name || ', ' || a1.spriden_first_name AS "Student_Name",
	b1.shrtckn_crn,
	b1.shrtckn_term_code,
	b1.shrtckn_ptrm_code,
	c1.*, 
	d1.*,
	e1.szrcmnt_crn AS "SCENT_Comment_CRN",
	e1.szrcmnt_comment AS "SCENT_Comment"
FROM
	spriden a1
	JOIN shrtckn b1 ON a1.spriden_pidm = b1.shrtckn_pidm
	LEFT JOIN szrmrks c1 ON a1.spriden_pidm = c1.pidm AND TO_CHAR(c1.crn) = TO_CHAR(b1.shrtckn_crn) AND c1.activity_date >= '01-MAY-20'
	LEFT JOIN szrcmnt d1 ON a1.spriden_pidm = d1.szrcmnt_pidm AND TO_CHAR(b1.shrtckn_crn) = TO_CHAR(d1.szrcmnt_crn) AND d1.szrcmnt_type = 'EXCOM' AND d1.szrcmnt_date >= '01-MAY-20'
	LEFT JOIN szrcmnt e1 ON a1.spriden_pidm = e1.szrcmnt_pidm AND TO_CHAR(b1.shrtckn_crn) = TO_CHAR(e1.szrcmnt_crn) AND e1.szrcmnt_type = 'SCENT' AND e1.szrcmnt_date >= '01-MAY-20'
	
WHERE
	1=1
	AND spriden_change_ind IS NULL
	AND spriden_pidm IN (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = :popsel_name)
	AND (
	
		c1.crn IS NOT NULL 
		OR
		d1.szrcmnt_crn IS NOT NULL
	)
	
ORDER BY 
	a1.spriden_id

;
