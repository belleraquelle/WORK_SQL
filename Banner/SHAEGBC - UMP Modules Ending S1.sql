SELECT
    *
FROM
    ssbsect
WHERE
    1=1
    AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb IN (
        SELECT gorsdav_pk_parenttab
        FROM gorsdav
        WHERE gorsdav_table_name = 'SCBCRKY' AND gorsdav_attr_name = 'UMP' AND sys.ANYDATA.accessvarchar2(gorsdav_value) = 'Y'
    )
    AND (
        (ssbsect_term_code = '201901' AND ssbsect_ptrm_code = 'S21')
        OR
        (ssbsect_term_code = '201906' AND ssbsect_ptrm_code = 'S31')
        OR
        (ssbsect_term_code = '201909' AND ssbsect_ptrm_code = 'S1')
    )
;