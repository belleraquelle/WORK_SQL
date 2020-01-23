SELECT
    spriden_id AS "Student_Number",
    spriden_first_name ||' ' || spriden_last_name AS "Student_Name",
    shrtckn_term_code AS "Term_Code",
    shrtckn_ptrm_code AS "Part_of_Term",
    shrtckn_crn AS "CRN",
    shrtckn_subj_code AS "Subject",
    shrtckn_crse_numb AS "Course_Number",
    shrtckn_crse_title AS "Module_Title",
    shrtckg_grde_code_final AS "Final_Grade"

FROM
    shrtckg s1
    JOIN shrtckn ON shrtckn_seq_no = shrtckg_tckn_seq_no AND shrtckn_pidm = s1.shrtckg_pidm AND shrtckn_term_code = s1.shrtckg_term_code
    JOIN spriden ON shrtckn_pidm = spriden_pidm AND spriden_change_ind IS NULL
    
WHERE 
    1=1

    -- Pick the latest grade for each module in Academic History
    AND s1.shrtckg_seq_no = (SELECT MAX(s2.shrtckg_seq_no) FROM shrtckg s2 WHERE s2.shrtckg_pidm = s1.shrtckg_pidm AND s2.shrtckg_term_code = s1.shrtckg_term_code AND s2.shrtckg_tckn_seq_no = s1.shrtckg_tckn_seq_no)

    -- Limit to grades of IC
    AND s1.shrtckg_grde_code_final = 'IC'
    
    -- Limit to modules running against specific part of terms, which are / aren't dissertations (e.g. L7DS) and which are / aren't UMP
    AND shrtckn_crn IN (
        SELECT
            ssbsect_crn
        FROM
            ssbsect

        WHERE
            1=1

            -- You can remove the NOT in the following section of the query to bring through UMP modules

            AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb IN (
                SELECT gorsdav_pk_parenttab
                FROM gorsdav
                WHERE gorsdav_table_name = 'SCBCRKY' AND gorsdav_attr_name = 'UMP' AND sys.ANYDATA.accessvarchar2(gorsdav_value) = 'Y'
            )

            AND CONCAT(ssbsect_subj_code, ssbsect_crse_numb) NOT IN (
                SELECT CONCAT(scrattr_subj_code, scrattr_crse_numb)
                FROM scrattr
                WHERE scrattr_attr_code = 'L7DS'
            )
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

ORDER BY
    shrtckn_term_code, 
    shrtckn_subj_code, 
    shrtckn_crse_numb,
    spriden_first_name ||' ' || spriden_last_name
;