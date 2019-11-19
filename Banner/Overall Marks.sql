SELECT 
    shrcmrk_term_code, 
    shrcmrk_crn, 
    ssbsect_subj_code, 
    ssbsect_crse_numb, 
    s1.spriden_id,
    s1.spriden_last_name || ', ' || s1.spriden_first_name AS "Student_Name",
    shrcmrk_percentage, 
    shrcmrk_grde_code, 
    shrcmrk_roll_date, 
    s2.spriden_last_name || ', ' || s2.spriden_first_name AS "Module_Leader"
FROM
    shrcmrk
    --JOIN shrgcom ON shrcmrk_term_code = shrgcom_term_code AND shrcmrk_crn = shrgcom_crn
    JOIN ssbsect ON shrcmrk_crn = ssbsect_crn AND shrcmrk_term_code = ssbsect_term_code
    --JOIN scbcrse ON ssbsect_subj_code = scbcrse_subj_code AND ssbsect_crse_numb = scbcrse_crse_numb -- Issue here with courses that have changed name over time. Would need to return the title that the section's term code falls within
    JOIN spriden s1 ON shrcmrk_pidm = s1.spriden_pidm and s1.spriden_change_ind IS NULL
    LEFT JOIN sirasgn ON sirasgn_term_code = ssbsect_term_code AND sirasgn_crn = ssbsect_crn AND sirasgn_primary_ind = 'Y'
    LEFT JOIN spriden s2 ON sirasgn_pidm = s2.spriden_pidm AND s2.spriden_change_ind IS NULL
WHERE
    1=1
    
    -- Only return module runs that meet these criteria
    AND shrcmrk_crn IN (
        SELECT
            ssbsect_crn
        FROM
            ssbsect
        WHERE
            1=1
            AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb NOT IN (
                SELECT gorsdav_pk_parenttab
                FROM gorsdav
                WHERE gorsdav_table_name = 'SCBCRKY' AND gorsdav_attr_name = 'UMP' AND sys.ANYDATA.accessvarchar2(gorsdav_value) = 'Y'
            )
            AND CONCAT(ssbsect_subj_code, ssbsect_crse_numb) IN (
                SELECT CONCAT(scrattr_subj_code, scrattr_crse_numb)
                FROM scrattr
                WHERE scrattr_attr_code = 'L7DS'
            )
            AND (
                (ssbsect_term_code = '201809' 
                    AND ssbsect_ptrm_code IN ('S13','T13','T14'))
                OR
                (ssbsect_term_code = '201901' 
                    AND ssbsect_ptrm_code IN ('S23','T23','T24','T3','T34'))
                OR
                (ssbsect_term_code = '201906' 
                    AND ssbsect_ptrm_code IN ('S3','T4'))
            )
    )
    
    -- Only include rows from the marks table where either the score of the grade is not null
    AND NOT (shrcmrk_percentage IS NULL OR shrcmrk_grde_code IS NULL)

ORDER BY
    shrcmrk_crn, s1.spriden_last_name, s1.spriden_id
;