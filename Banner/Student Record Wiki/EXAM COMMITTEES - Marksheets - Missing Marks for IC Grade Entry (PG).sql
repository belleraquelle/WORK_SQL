SELECT 
	ssbsect_term_code AS "Term_Code",
    ssbsect_crn AS "CRN",
    sfrstcr_pidm AS "PIDM",
    ssbsect_subj_code AS "Subject_Code", 
    ssbsect_crse_numb AS "Course_Number",
    scbcrse_title AS "Module_Title",
    ssbsect_camp_code AS "Campus_Code",
    ssbsect_ptrm_code AS "Part_of_Term",
    ssbsect_ptrm_start_date AS "Module_Start_Date",
    ssbsect_ptrm_end_date AS "Module_End_Date",
    sfrstcr_rsts_code AS "Registration_Status",
    s1.spriden_id AS "Student_Number",
    s1.spriden_last_name || ', ' || s1.spriden_first_name AS "Student_Name",
    sfrstcr_grde_code AS "Component_Grade"
    
FROM
    shrmrks
    JOIN shrgcom ON shrmrks_term_code = shrgcom_term_code AND shrmrks_crn = shrgcom_crn  AND shrmrks_gcom_id = shrgcom_id
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    JOIN scbcrse c1 ON ssbsect_subj_code = c1.scbcrse_subj_code AND ssbsect_crse_numb = c1.scbcrse_crse_numb AND c1.scbcrse_eff_term = (SELECT MAX(c2.scbcrse_eff_term) FROM scbcrse c2 WHERE c2.scbcrse_subj_code = c1.scbcrse_subj_code AND c2.scbcrse_crse_numb = c1.scbcrse_crse_numb) -- Issue here with courses that have changed name over time. Would need to return the title that the section's term code falls within
    JOIN spriden s1 ON shrmrks_pidm = s1.spriden_pidm and s1.spriden_change_ind IS NULL
    JOIN sfrstcr ON shrmrks_term_code = sfrstcr_term_code AND shrmrks_crn = sfrstcr_crn AND shrmrks_pidm = sfrstcr_pidm
    JOIN sorlcur a1 ON sfrstcr_pidm = a1.sorlcur_pidm AND sfrstcr_stsp_key_sequence = a1.sorlcur_key_seqno
    LEFT JOIN sirasgn ON sirasgn_term_code = ssbsect_term_code AND sirasgn_crn = ssbsect_crn AND sirasgn_primary_ind = 'Y'
    LEFT JOIN spriden s2 ON sirasgn_pidm = s2.spriden_pidm AND s2.spriden_change_ind IS NULL
    
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
            AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb NOT IN (
                SELECT gorsdav_pk_parenttab
                FROM gorsdav
                WHERE gorsdav_table_name = 'SCBCRKY' AND gorsdav_attr_name = 'UMP' AND sys.ANYDATA.accessvarchar2(gorsdav_value) = 'Y'
            )
            
            -- Specify L7 Dissertation 
            AND CONCAT(ssbsect_subj_code, ssbsect_crse_numb) NOT IN (
                SELECT CONCAT(scrattr_subj_code, scrattr_crse_numb)
                FROM scrattr
                WHERE scrattr_attr_code = 'L7DS'
            )
            
            -- Limit to modules that end between specified dates
            AND sobptrm_end_date BETWEEN :MODULE_END_DATE_RANGE_START AND :MODULE_END_DATE_RANGE_END
            
        )

    -- Limit to students missing an overall grade
    AND sfrstcr_grde_code IS NULL
	
    -- Only include students who are still registered on the module
    AND sfrstcr_rsts_code IN ('RE','RW', 'RC')
    
    -- Limit to Brookes / Collaborative Provision
    AND ssbsect_camp_code IN ('OBO', 'OBS', 'DL')
    
    -- Pull through max SORLCUR record
    AND a1.sorlcur_term_code = (
    	SELECT MAX (a2.sorlcur_term_code)
    	FROM sorlcur a2
    	WHERE 
    		1=1
    		AND a1.sorlcur_pidm = a2.sorlcur_pidm
    		AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno
    		AND a2.sorlcur_lmod_code = 'LEARNER'
    		AND a2.sorlcur_cact_code = 'ACTIVE'
    		AND a2.sorlcur_current_cde = 'Y'
    )
    AND a1.sorlcur_lmod_code = 'LEARNER'
    AND a1.sorlcur_cact_code = 'ACTIVE'
    AND a1.sorlcur_current_cde = 'Y'
    
    -- Limit to students from specified courses or specified faculty
    AND (a1.sorlcur_program IN :PROGRAMME_LIST OR a1.sorlcur_coll_code = :FACULTY_CODE)
    

ORDER BY
    shrmrks_crn, shrgcom_name, shrgcom_description, s1.spriden_last_name, s1.spriden_id
;




SELECT * FROM sorlcur;