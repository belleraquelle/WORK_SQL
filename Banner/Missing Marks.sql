/* 
The query below pulls through all of the student + components that are missing a mark/grade where the module is flagged as L7DS in SCRATTR
and ends around September and so will be considered at the December Committees 
*/

SELECT 
    shrmrks_term_code, 
    shrmrks_crn, 
    ssbsect_subj_code, 
    ssbsect_crse_numb, 
    shrgcom_name, 
    shrgcom_description,
    shrgcom_weight, 
    s1.spriden_id,
    s1.spriden_last_name || ', ' || s1.spriden_first_name AS "Student_Name",
    shrmrks_score, 
    shrmrks_percentage, 
    shrmrks_grde_code, 
    shrmrks_comments, 
    shrmrks_completed_date, 
    shrmrks_roll_date, 
    shrmrks_data_origin,
    s2.spriden_last_name || ', ' || s2.spriden_first_name AS "Module_Leader"
FROM
    shrmrks
    JOIN shrgcom ON shrmrks_term_code = shrgcom_term_code AND shrmrks_crn = shrgcom_crn  AND shrmrks_gcom_id = shrgcom_id
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    --JOIN scbcrse ON ssbsect_subj_code = scbcrse_subj_code AND ssbsect_crse_numb = scbcrse_crse_numb -- Issue here with courses that have changed name over time. Would need to return the title that the section's term code falls within
    JOIN spriden s1 ON shrmrks_pidm = s1.spriden_pidm and s1.spriden_change_ind IS NULL
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
    
    -- Only include rows from the marks table where either the score of the grade is null
    AND (shrmrks_score IS NULL OR shrmrks_grde_code IS NULL)

ORDER BY
    shrmrks_crn, shrgcom_name, shrgcom_description, s1.spriden_last_name, s1.spriden_id
;