/* 

CRNS with grades that haven't been rolled

*/

SELECT DISTINCT
    shrmrks_term_code, 
    shrmrks_crn, 
    ssbsect_subj_code, 
    ssbsect_crse_numb,
    scbcrse_title,
    ssbsect_camp_code
    
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
        WHERE
            1=1

            -- You can remove the NOT in the following section of the query to bring through UMP modules

            AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb NOT IN (
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

    -- Only include students who are still registered on the module
    AND sfrstcr_rsts_code IN ('RE','RW')
    
	-- Only include CRNs with grades that need to be rolled
	AND shrtckn_crn IS NULL
	
ORDER BY
	ssbsect_subj_code,
	ssbsect_crse_numb,
	shrmrks_term_code,
	ssbsect_camp_code
;