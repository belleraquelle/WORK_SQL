/*

This report will bring back any modules from academic history where the student has either a DD comment against a component or
a DD overall grade. 

Various controls will limit the report to certain module selections (e.g. UMP vs non-UMP).

Can be used to ensure consistency between component comments and final grades.

*/

SELECT DISTINCT
    shrmrks_term_code, 
    shrmrks_crn, 
    ssbsect_subj_code, 
    ssbsect_crse_numb,
    ssbsect_camp_code,
    s1.spriden_id,
    s1.spriden_last_name || ', ' || s1.spriden_first_name AS "Student_Name",
    CASE 
        WHEN s1.spriden_id||shrtckn_term_code||shrtckn_crn IN (
            SELECT spriden_id||shrmrks_term_code||shrmrks_crn 
            FROM shrmrks JOIN spriden ON shrmrks_pidm = spriden_pidm
            WHERE shrmrks_comments = 'Deferred Disciplinary'
        ) THEN 'DD component comment'
        ELSE 'No DD component comment'
        END AS "DD_Comment",
    shrtckg_grde_code_final

FROM
    shrmrks
    JOIN shrgcom ON shrmrks_term_code = shrgcom_term_code AND shrmrks_crn = shrgcom_crn  AND shrmrks_gcom_id = shrgcom_id
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    JOIN spriden s1 ON shrmrks_pidm = s1.spriden_pidm and s1.spriden_change_ind IS NULL
    JOIN shrtckn ON shrmrks_pidm = shrtckn_pidm AND shrtckn_term_code = shrmrks_term_code AND shrtckn_crn = shrmrks_crn
    JOIN shrtckg t1 ON shrtckn_seq_no = shrtckg_tckn_seq_no AND shrtckn_pidm = t1.shrtckg_pidm AND shrtckn_term_code = t1.shrtckg_term_code
    
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

            -- You can remove / add a NOT in the following section of the query to bring through UMP / Non-UMP modules

            AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb IN (
                SELECT gorsdav_pk_parenttab
                FROM gorsdav
                WHERE gorsdav_table_name = 'SCBCRKY' AND gorsdav_attr_name = 'UMP' AND sys.ANYDATA.accessvarchar2(gorsdav_value) = 'Y'
            )
            
            -- Use this clause to control whether or not you see modules with particular attributes
            AND CONCAT(ssbsect_subj_code, ssbsect_crse_numb) NOT IN (
                SELECT CONCAT(scrattr_subj_code, scrattr_crse_numb)
                FROM scrattr
                WHERE scrattr_attr_code = 'L7DS'
            )
            
            -- Use this clause to only bring back modules attached to particular terms / part-of-terms
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
    
    -- Pick the latest grade for each module in Academic History
    AND t1.shrtckg_seq_no = (SELECT MAX(t2.shrtckg_seq_no) FROM shrtckg t2 WHERE t2.shrtckg_pidm = t1.shrtckg_pidm AND t2.shrtckg_term_code = t1.shrtckg_term_code AND t2.shrtckg_tckn_seq_no = t1.shrtckg_tckn_seq_no)

    -- Only include rows with a deferred disciplinary comment OR a DD grade
    AND (shrmrks_comments IN ('Deferred Disciplinary') OR shrtckg_grde_code_final = 'DD')

ORDER BY
    shrmrks_crn
;