
/*

This will return students who were eligible for a resit on modules that ended between the specified dates. This can be used to identify components we are still expecting resit results for.

*/

SELECT 
    shrmrks_term_code, 
    shrmrks_crn, 
    ssbsect_subj_code, 
    ssbsect_crse_numb,
    scbcrse_title,
    ssbsect_camp_code,
    ssbsect_ptrm_code,
    s1.spriden_id,
    s1.spriden_last_name || ', ' || s1.spriden_first_name AS "Student_Name",
    --sfrstcr_rsts_code,
    shrgcom_name, 
    shrgcom_description,
    shrgcom_weight, 
    shrmrks_gcom_id,
    shrmrks_score, 
    shrmrks_percentage, 
    shrmrks_grde_code, 
    shrmrks_gchg_code,
    shrtckg_grde_code_final,
    shrmrks_comments, 
    shrmrks_completed_date, 
    shrmrks_roll_date, 
    shrmrks_data_origin,
    s2.spriden_last_name || ', ' || s2.spriden_first_name AS "Module_Leader"
FROM
    shrmrks
    JOIN shrgcom ON shrmrks_term_code = shrgcom_term_code AND shrmrks_crn = shrgcom_crn  AND shrmrks_gcom_id = shrgcom_id
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    JOIN scbcrse c1 ON ssbsect_subj_code = c1.scbcrse_subj_code AND ssbsect_crse_numb = c1.scbcrse_crse_numb AND c1.scbcrse_eff_term = (SELECT MAX(c2.scbcrse_eff_term) FROM scbcrse c2 WHERE c2.scbcrse_subj_code = c1.scbcrse_subj_code AND c2.scbcrse_crse_numb = c1.scbcrse_crse_numb) -- Issue here with courses that have changed name over time. Would need to return the title that the section's term code falls within
    JOIN spriden s1 ON shrmrks_pidm = s1.spriden_pidm and s1.spriden_change_ind IS NULL
    JOIN sfrstcr ON shrmrks_term_code = sfrstcr_term_code AND shrmrks_crn = sfrstcr_crn AND shrmrks_pidm = sfrstcr_pidm
    JOIN shrtckn ON shrmrks_pidm = shrtckn_pidm AND shrtckn_term_code = shrmrks_term_code AND shrtckn_crn = shrmrks_crn
    JOIN shrtckg t1 ON shrtckn_seq_no = shrtckg_tckn_seq_no AND shrtckn_pidm = t1.shrtckg_pidm AND shrtckn_term_code = t1.shrtckg_term_code
    LEFT JOIN sirasgn ON sirasgn_term_code = ssbsect_term_code AND sirasgn_crn = ssbsect_crn AND sirasgn_primary_ind = 'Y'
    LEFT JOIN spriden s2 ON sirasgn_pidm = s2.spriden_pidm AND s2.spriden_change_ind IS NULL
WHERE
    1=1

    -- Pick the latest grade for each module in Academic History
    AND t1.shrtckg_seq_no = (SELECT MAX(t2.shrtckg_seq_no) FROM shrtckg t2 WHERE t2.shrtckg_pidm = t1.shrtckg_pidm AND t2.shrtckg_term_code = t1.shrtckg_term_code AND t2.shrtckg_tckn_seq_no = t1.shrtckg_tckn_seq_no)

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
    
    -- Limit to Brookes / Collaborative Provision
    AND ssbsect_camp_code :IN_FOR_BROOKES_NOT_IN_FOR_ACP ('OBO', 'OBS', 'DL')
    
    -- Exclude anyone with a DR grade
    AND shrtckg_grde_code_final IN ('F', 'FAIL')

    AND (
            -- Limit to components that are eligible for a resit
            (
                (shrmrks_comments IS NULL OR shrmrks_comments = 'Exceptional Circumstances') -- Student has a null comment (i.e. they've attempted) or the comment is Exceptional Circumstances
                AND (shrmrks_grde_code IN ('F', 'FAIL') OR shrmrks_comments = 'Exceptional Circumstances') -- Student has failed a component or the comment is Exceptional Circumstances
                AND (shrtckg_grde_code_final IN ('F','FAIL') OR shrmrks_comments = 'Exceptional Circumstances') -- Student has failed the module overall or the comment is Exceptional Circumstances
            )
            -- And exclude students who have had a resit grade entered
            AND (shrmrks_gchg_code NOT IN ('RE', 'UR', 'CR'))
        )
        
    -- Limit to capped resits
    --AND shrmrks_comments IS NULL
     
    -- Exclude students who have a Not Attempted comment on ANY component for that CRN
 	AND shrmrks_pidm || shrmrks_term_code || shrmrks_crn NOT IN (
 	
 		SELECT shrmrks_pidm || shrmrks_term_code || shrmrks_crn
 		FROM shrmrks
 		WHERE shrmrks_comments = 'Not Attempted'
 	
 	)
 	
ORDER BY
    shrmrks_crn, shrgcom_name, shrgcom_description, s1.spriden_last_name, s1.spriden_id
;
