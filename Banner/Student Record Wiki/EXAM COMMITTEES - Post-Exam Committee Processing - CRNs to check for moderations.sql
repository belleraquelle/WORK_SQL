/*
 * 
 * This query will return CRNs that ended between the dates specified with student's registered.
 * 
 * It includes the relevant details from SHAEGBC related to grade entry windows and result release dates.
 * 
 * The first column will have 'Y' if there are any resit moderations or moderation comments entered after the resit upload deadline recorded on the Mark Moderation Portal.
 * 
 */


SELECT DISTINCT
	CASE
		WHEN szrcmnt_crn IS NOT NULL OR crn IS NOT NULL THEN 'Y'
		ELSE NULL
	END AS "Moderations?",
	scbcrse_coll_code AS "Faculty",
    shrmrks_term_code AS "Term_Code", 
    shrmrks_crn AS "CRN", 
    ssbsect_subj_code AS "Subject_Code", 
    ssbsect_crse_numb AS "Course_Number",
    scbcrse_title AS "Module_Title",
    ssbsect_camp_code AS "Campus",
    ssbsect_ptrm_code AS "Part_of_Term",
    ssbsect_ptrm_start_date AS "Start_Date",
    ssbsect_ptrm_end_date AS "End_Date",
    ssbsect_score_open_date,
    ssbsect_score_cutoff_date,
    ssbsect_reas_score_open_date,
    ssbsect_reas_score_ctof_date,
    ssbssec_final_grde_pub_date,
    ssbssec_det_grde_pub_date,
    ssbssec_reas_grde_pub_date,
    ssbssec_reas_det_grde_pub_date

FROM
    shrmrks
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    JOIN scbcrse c1 ON ssbsect_subj_code = c1.scbcrse_subj_code AND ssbsect_crse_numb = c1.scbcrse_crse_numb AND c1.scbcrse_eff_term = (SELECT MAX(c2.scbcrse_eff_term) FROM scbcrse c2 WHERE c2.scbcrse_subj_code = c1.scbcrse_subj_code AND c2.scbcrse_crse_numb = c1.scbcrse_crse_numb) -- Issue here with courses that have changed name over time. Would need to return the title that the section's term code falls within
    JOIN sfrstcr ON shrmrks_term_code = sfrstcr_term_code AND shrmrks_crn = sfrstcr_crn AND shrmrks_pidm = sfrstcr_pidm
    LEFT JOIN ssbssec ON ssbsect_crn = ssbssec_crn AND ssbsect_term_code = ssbssec_term_code
    LEFT JOIN szrmrks ON shrmrks_term_code = term_code AND shrmrks_crn = crn
    LEFT JOIN szrcmnt ON shrmrks_crn = szrcmnt_crn
    
WHERE
    1=1

    -- Only return module runs that meet these part of term criteria
    AND shrmrks_crn IN (
        
    	SELECT
            ssbsect_crn
            
        FROM
            ssbsect
            JOIN sobptrm ON ssbsect_term_code = sobptrm_term_code AND ssbsect_ptrm_code = sobptrm_ptrm_code
            
        WHERE
            1=1

            -- Specify UMP / Non-UMP Modules
            AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb :IN_FOR_UMP_NOT_IN_FOR_NON_UMP (
                SELECT gorsdav_pk_parenttab
                FROM gorsdav
                WHERE gorsdav_table_name = 'SCBCRKY' AND gorsdav_attr_name = 'UMP' AND sys.ANYDATA.accessvarchar2(gorsdav_value) = 'Y'
            )
            
            -- Specify L7 Dissertation 
            AND CONCAT(ssbsect_subj_code, ssbsect_crse_numb) :IN_FOR_L7_DIS_NOT_IN_FOR_NOT_L7_DIS (
                SELECT CONCAT(scrattr_subj_code, scrattr_crse_numb)
                FROM scrattr
                WHERE scrattr_attr_code = 'L7DS'
            )
            
            -- Limit to modules that end between specified dates
            AND sobptrm_end_date BETWEEN :MODULE_END_DATE_RANGE_START AND :MODULE_END_DATE_RANGE_END	
    
	)
	
     -- Only include students who are still registered on the module
    AND sfrstcr_rsts_code IN ('RE','RW', 'RC')
	
	-- Limit to Brookes / Collaborative Provision
    AND ssbsect_camp_code :IN_FOR_BROOKES_NOT_IN_FOR_ACP ('OBO', 'OBS', 'DL')
    
    -- Optional faculty filter
    --AND scbcrse_coll_code = :FACULTY_CODE

ORDER BY
    ssbsect_subj_code, ssbsect_crse_numb
;


/*
 * 
 * This query will return CRNs that ended between the dates specified and which have any components reported with a resit grade change code.
 * 
 * It includes the relevant details from SHAEGBC related to grade entry windows and result release dates.
 * 
 * The first column will have 'Y' if there are any resit moderations or moderation comments entered after the resit upload deadline recorded on the Mark Moderation Portal.
 * 
 */

SELECT DISTINCT

	CASE
		WHEN 
			shrmrks_crn IN (SELECT crn FROM szrmrks WHERE resit_ind = 'Y' )
			OR
			shrmrks_crn IN (SELECT szrcmnt_crn FROM szrcmnt WHERE szrcmnt_date >= ssbsect_reas_score_ctof_date)
		THEN 'Y'
		ELSE NULL
	END AS "Moderations?",

--	CASE
--		WHEN szrcmnt_crn IS NOT NULL OR crn IS NOT NULL THEN 'Y'
--		ELSE NULL
--	END AS "Moderations?",
	scbcrse_coll_code AS "Faculty",
    shrmrks_term_code AS "Term_Code", 
    shrmrks_crn AS "CRN", 
    ssbsect_subj_code AS "Subject_Code", 
    ssbsect_crse_numb AS "Course_Number",
    scbcrse_title AS "Module_Title",
    ssbsect_camp_code AS "Campus",
    ssbsect_ptrm_code AS "Part_of_Term",
    ssbsect_ptrm_start_date AS "Start_Date",
    ssbsect_ptrm_end_date AS "End_Date",
    ssbsect_score_open_date,
    ssbsect_score_cutoff_date,
    ssbsect_reas_score_open_date,
    ssbsect_reas_score_ctof_date,
    ssbssec_final_grde_pub_date,
    ssbssec_det_grde_pub_date,
    ssbssec_reas_grde_pub_date,
    ssbssec_reas_det_grde_pub_date

FROM
    shrmrks
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    JOIN scbcrse c1 ON ssbsect_subj_code = c1.scbcrse_subj_code AND ssbsect_crse_numb = c1.scbcrse_crse_numb AND c1.scbcrse_eff_term = (SELECT MAX(c2.scbcrse_eff_term) FROM scbcrse c2 WHERE c2.scbcrse_subj_code = c1.scbcrse_subj_code AND c2.scbcrse_crse_numb = c1.scbcrse_crse_numb) -- Issue here with courses that have changed name over time. Would need to return the title that the section's term code falls within
    JOIN sfrstcr ON shrmrks_term_code = sfrstcr_term_code AND shrmrks_crn = sfrstcr_crn AND shrmrks_pidm = sfrstcr_pidm
    LEFT JOIN ssbssec ON ssbsect_crn = ssbssec_crn AND ssbsect_term_code = ssbssec_term_code
    
WHERE
    1=1

    -- Only return module runs that meet these part of term criteria
    AND shrmrks_crn IN (
        
    	SELECT
            ssbsect_crn
            
        FROM
            ssbsect
            JOIN sobptrm ON ssbsect_term_code = sobptrm_term_code AND ssbsect_ptrm_code = sobptrm_ptrm_code
            
        WHERE
            1=1

            -- Specify UMP / Non-UMP Modules
            AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb :IN_FOR_UMP_NOT_IN_FOR_NON_UMP (
                SELECT gorsdav_pk_parenttab
                FROM gorsdav
                WHERE gorsdav_table_name = 'SCBCRKY' AND gorsdav_attr_name = 'UMP' AND sys.ANYDATA.accessvarchar2(gorsdav_value) = 'Y'
            )
            
            -- Specify L7 Dissertation 
            AND CONCAT(ssbsect_subj_code, ssbsect_crse_numb) :IN_FOR_L7_DIS_NOT_IN_FOR_NOT_L7_DIS (
                SELECT CONCAT(scrattr_subj_code, scrattr_crse_numb)
                FROM scrattr
                WHERE scrattr_attr_code = 'L7DS'
            )
            
            -- Limit to modules that end between specified dates
            AND sobptrm_end_date BETWEEN :MODULE_END_DATE_RANGE_START AND :MODULE_END_DATE_RANGE_END	
    
	)
	
     -- Only include students who are still registered on the module
    AND sfrstcr_rsts_code IN ('RE','RW', 'RC')
	
	-- Limit to Brookes / Collaborative Provision
    AND ssbsect_camp_code :IN_FOR_BROOKES_NOT_IN_FOR_ACP ('OBO', 'OBS', 'DL')
    
    -- Limit to resits
    AND shrmrks_gchg_code IN ('CR','UR','RE')
    
    -- Optional faculty filter
    --AND scbcrse_coll_code = :FACULTY_CODE

ORDER BY
    ssbsect_subj_code, ssbsect_crse_numb
;


SELECT * FROM scbcrse