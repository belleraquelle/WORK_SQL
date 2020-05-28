/* 

CRNS with grades that haven't been rolled

*/

SELECT DISTINCT
    shrmrks_term_code AS "Term_Code", 
    shrmrks_crn AS "CRN", 
    ssbsect_subj_code AS "Subject_Code", 
    ssbsect_crse_numb AS "Course_Number",
    scbcrse_title AS "Module_Title",
    ssbsect_camp_code AS "Campus_Code"
    
FROM
    shrmrks
    JOIN shrgcom ON shrmrks_term_code = shrgcom_term_code AND shrmrks_crn = shrgcom_crn  AND shrmrks_gcom_id = shrgcom_id
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    JOIN scbcrse c1 ON ssbsect_subj_code = c1.scbcrse_subj_code AND ssbsect_crse_numb = c1.scbcrse_crse_numb AND c1.scbcrse_eff_term = (SELECT MAX(c2.scbcrse_eff_term) FROM scbcrse c2 WHERE c2.scbcrse_subj_code = c1.scbcrse_subj_code AND c2.scbcrse_crse_numb = c1.scbcrse_crse_numb) -- Issue here with courses that have changed name over time. Would need to return the title that the section's term code falls within
    JOIN spriden s1 ON shrmrks_pidm = s1.spriden_pidm and s1.spriden_change_ind IS NULL
    JOIN sfrstcr ON shrmrks_term_code = sfrstcr_term_code AND shrmrks_crn = sfrstcr_crn AND shrmrks_pidm = sfrstcr_pidm
    LEFT JOIN shrtckn ON shrmrks_pidm = shrtckn_pidm AND shrmrks_crn = shrtckn_crn AND shrmrks_term_code = shrtckn_term_code
    
WHERE
    1=1

    -- Only return module runs that meet these criteria
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
    
	-- Only include CRNs with grades that need to be rolled
	AND shrtckn_crn IS NULL
	
ORDER BY
	ssbsect_subj_code,
	ssbsect_crse_numb,
	shrmrks_term_code,
	ssbsect_camp_code
;