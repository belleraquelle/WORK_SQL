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
    shrmrks_score, 
    shrmrks_percentage, 
    shrmrks_grde_code, 
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
        WHERE
            1=1

            -- You can remove the NOT in the following section of the query to bring through UMP modules

--            AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb IN (
--                SELECT gorsdav_pk_parenttab
--                FROM gorsdav
--                WHERE gorsdav_table_name = 'SCBCRKY' AND gorsdav_attr_name = 'UMP' AND sys.ANYDATA.accessvarchar2(gorsdav_value) = 'Y'
--            )
--
--            AND CONCAT(ssbsect_subj_code, ssbsect_crse_numb) NOT IN (
--                SELECT CONCAT(scrattr_subj_code, scrattr_crse_numb)
--                FROM scrattr
--                WHERE scrattr_attr_code = 'L7DS'
--            )
            AND (
                (ssbsect_term_code = '201901' 
                    AND ssbsect_ptrm_code IN ('S21', 'T21', 'T31', 'E10', 'E12', 'F10', 'G10', 'I8'))
                OR
                (ssbsect_term_code = '201906' 
                    AND ssbsect_ptrm_code IN ('S31', 'T41', 'J5','J7', 'K5'))
                OR
                (ssbsect_term_code = '201909' 
                    AND ssbsect_ptrm_code IN ('S1', 'T1', 'A2', 'A3', 'A4', 'B1', 'D1'))
                )
        )

    -- Only include rows from the marks table where the score is equal to zero and no component comment has been entered
    AND (shrmrks_comments IS NULL OR shrmrks_comments = 'Exceptional Circumstances')

    -- Only include students who are still registered on the module
    AND sfrstcr_rsts_code IN ('RE','RW')

    -- Limit by campus
    AND ssbsect_camp_code IN ('OBO', 'OBS', 'DL')

    --AND shrgcom_description LIKE '%Exam%'


    AND (shrmrks_grde_code IN ('F', 'FAIL') OR shrmrks_comments = 'Exceptional Circumstances')

    -- Only include instances where either the overall grade is a fail OR the student has exceptional circumstances for the component
    AND (shrtckg_grde_code_final IN ('F','FAIL') OR shrmrks_comments = 'Exceptional Circumstances')
    
    -- Specify a CRN
    AND shrmrks_crn IN ('3308', '3309')

ORDER BY
    shrmrks_crn, shrgcom_name, shrgcom_description, s1.spriden_last_name, s1.spriden_id