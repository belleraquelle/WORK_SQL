SELECT DISTINCT
    shrmrks_term_code, 
    shrmrks_crn, 
    ssbsect_subj_code, 
    ssbsect_crse_numb,
    scbcrse_title,
    ssbsect_camp_code,
    ssbsect_ptrm_code,
    ssbsect_ptrm_start_date,
    ssbsect_ptrm_end_date,
    ssbsect_score_open_date,
    ssbsect_score_cutoff_date,
    ssbsect_reas_score_open_date,
    ssbsect_reas_score_ctof_date,
    ssbssec_final_grde_pub_date,
    ssbssec_det_grde_pub_date,
    ssbssec_reas_grde_pub_date,
    ssbssec_reas_det_grde_pub_date

FROM
    shrmrks
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    JOIN scbcrse c1 ON ssbsect_subj_code = c1.scbcrse_subj_code AND ssbsect_crse_numb = c1.scbcrse_crse_numb AND c1.scbcrse_eff_term = (SELECT MAX(c2.scbcrse_eff_term) FROM scbcrse c2 WHERE c2.scbcrse_subj_code = c1.scbcrse_subj_code AND c2.scbcrse_crse_numb = c1.scbcrse_crse_numb) -- Issue here with courses that have changed name over time. Would need to return the title that the section's term code falls within
    JOIN sfrstcr ON shrmrks_term_code = sfrstcr_term_code AND shrmrks_crn = sfrstcr_crn AND shrmrks_pidm = sfrstcr_pidm
    LEFT JOIN ssbssec ON ssbsect_crn = ssbssec_crn AND ssbsect_term_code = ssbssec_term_code
    
WHERE
    1=1

    -- Only return module runs that meet these part of term criteria
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
	
    -- Only include where modules have students registered
    AND sfrstcr_rsts_code IN ('RE','RW')
    
    -- Limit to 'off-campus' campuses
    -- AND ssbsect_camp_code NOT IN ('OBO', 'OBS')

ORDER BY
    ssbsect_subj_code, ssbsect_crse_numb
;