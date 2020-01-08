/*

Query to identify PG students registered on a module ending S1 for
consideration at the January 2020 committees

*/

SELECT DISTINCT
    spriden_id

FROM
    sfrstcr
    JOIN ssbsect ON sfrstcr_crn = ssbsect_crn AND sfrstcr_term_code = ssbsect_term_code
    JOIN sorlcur ON sfrstcr_pidm = sorlcur_pidm
    JOIN spriden ON spriden_pidm = sfrstcr_pidm AND spriden_change_ind IS NULL
    
WHERE
    1=1
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
            AND ssbsect_ptrm_code IN ('S21'))
        OR
        (ssbsect_term_code = '201906' 
            AND ssbsect_ptrm_code IN ('S31'))
        OR
        (ssbsect_term_code = '201909' 
            AND ssbsect_ptrm_code IN ('S1'))
    )
    AND ssbsect_subj_code != 'FEE'
;