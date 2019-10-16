
/* The query below pulls through all of the modules flagged as L7DS in SCRATTR
which ends around September and so will be considered at the December Committees
*/

SELECT
    *
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
        (ssbsect_term_code = '201909' 
            AND ssbsect_ptrm_code IN ('S13','A10','B10','B9','C9','D9','T13','T14'))
        OR
        (ssbsect_term_code = '202001' 
            AND ssbsect_ptrm_code IN ('S23','E6','E8','G4','G6','H3','H5','T23','T24','T3','T34'))
        OR
        (ssbsect_term_code = '202006' AND ssbsect_ptrm_code = 'S3','J3','T4')
    )
;