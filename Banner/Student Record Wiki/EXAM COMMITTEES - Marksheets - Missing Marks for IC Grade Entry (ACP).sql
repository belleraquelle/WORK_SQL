SELECT 
	ssbsect_term_code,
    ssbsect_crn,
    sfrstcr_pidm,
    ssbsect_subj_code, 
    ssbsect_crse_numb,
    scbcrse_title,
    ssbsect_camp_code,
    ssbsect_ptrm_code,
    ssbsect_ptrm_start_date,
    ssbsect_ptrm_end_date,
    sfrstcr_rsts_code,
    s1.spriden_id,
    s1.spriden_last_name || ', ' || s1.spriden_first_name AS "Student_Name",
    sfrstcr_grde_code
    
FROM
    shrmrks
    JOIN shrgcom ON shrmrks_term_code = shrgcom_term_code AND shrmrks_crn = shrgcom_crn  AND shrmrks_gcom_id = shrgcom_id
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    JOIN scbcrse c1 ON ssbsect_subj_code = c1.scbcrse_subj_code AND ssbsect_crse_numb = c1.scbcrse_crse_numb AND c1.scbcrse_eff_term = (SELECT MAX(c2.scbcrse_eff_term) FROM scbcrse c2 WHERE c2.scbcrse_subj_code = c1.scbcrse_subj_code AND c2.scbcrse_crse_numb = c1.scbcrse_crse_numb) -- Issue here with courses that have changed name over time. Would need to return the title that the section's term code falls within
    JOIN spriden s1 ON shrmrks_pidm = s1.spriden_pidm and s1.spriden_change_ind IS NULL
    JOIN sfrstcr ON shrmrks_term_code = sfrstcr_term_code AND shrmrks_crn = sfrstcr_crn AND shrmrks_pidm = sfrstcr_pidm
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
            
            -- Limit to modules that end between specified dates
            AND sobptrm_end_date BETWEEN :MODULE_END_DATE_RANGE_START AND :MODULE_END_DATE_RANGE_END
            
        )

    -- Limit to students missing an overall grade
    AND sfrstcr_grde_code IS NULL
	
    -- Only include students who are still registered on the module
    AND sfrstcr_rsts_code IN ('RE','RW', 'RC')
    
    -- Limit to Brookes / Collaborative Provision
    AND ssbsect_camp_code NOT IN ('OBO', 'OBS', 'DL')

ORDER BY
    shrmrks_crn, shrgcom_name, shrgcom_description, s1.spriden_last_name, s1.spriden_id
;