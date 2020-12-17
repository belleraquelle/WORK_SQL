SELECT
	a1.spriden_last_name AS "Student_Last_Name",
	a1.spriden_first_name AS "Student_First_Name",
	a1.spriden_id AS "Spriden_ID", 
	b1.shrtckn_term_code AS "Term_Code",
	b1.shrtckn_crn AS "CRN",
	b1.shrtckn_subj_code || b1.shrtckn_crse_numb AS "Module_Number",
	--b1.shrtckn_ptrm_code AS "Part_of_Term",
	--c1.term_code AS "Component_Term_Code",
	--c1.crn AS "Component_CRN",
	--c1.gcom_id AS "Component_ID",
	f1.shrgcom_name AS "Component_Name",
	f1.shrgcom_description AS "Component_Description",
	f1.shrgcom_weight AS "Component_Weight",
	--f1.shrgcom_seq_no AS "Component_Sequence_Number",
	c1.mark AS "Mark",
	c1.prop_comment AS "Component_Comment",
	c1.resit_ind AS "Resit_Moderation",
	--c1.activity_date AS "Mark_Activity_Date",
	--d1.szrcmnt_crn AS "Moderation_Comment_CRN",
	d1.szrcmnt_date AS "Moderation_Comment_Date",
	d1.szrcmnt_comment AS "Moderation_Comment"
	--,e1.szrcmnt_crn AS "SCENT_Comment_CRN"
	--,e1.szrcmnt_comment AS "SCENT_Comment",
	--,e1.szrcmnt_date AS "SCENT_Comment_Date"
FROM
	spriden a1
	JOIN shrtckn b1 ON a1.spriden_pidm = b1.shrtckn_pidm
	LEFT JOIN szrmrks c1 ON a1.spriden_pidm = c1.pidm AND TO_CHAR(c1.crn) = TO_CHAR(b1.shrtckn_crn) AND c1.activity_date > :activity_date_after
	LEFT JOIN szrcmnt d1 ON a1.spriden_pidm = d1.szrcmnt_pidm AND TO_CHAR(b1.shrtckn_crn) = TO_CHAR(d1.szrcmnt_crn) AND d1.szrcmnt_type = 'EXCOM' AND d1.szrcmnt_date > :activity_date_after
	LEFT JOIN szrcmnt e1 ON a1.spriden_pidm = e1.szrcmnt_pidm AND TO_CHAR(b1.shrtckn_crn) = TO_CHAR(e1.szrcmnt_crn) AND e1.szrcmnt_type = 'SCENT' AND e1.szrcmnt_date > :activity_date_after
	LEFT JOIN shrgcom f1 ON c1.term_code = f1.shrgcom_term_code AND c1.crn = f1.shrgcom_crn AND c1.gcom_id = f1.shrgcom_id
	
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
	a1.spriden_last_name,
	a1.spriden_first_name,
	a1.spriden_id,
	b1.shrtckn_term_code,
	b1.shrtckn_crn
;