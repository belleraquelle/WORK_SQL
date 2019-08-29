SELECT DISTINCT 
    spriden_id, 
    spriden_last_name , 
    spriden_first_name, 
    goremal_email_address, 
    sprhold_hldd_code, 
    sprhold_from_date, 
    sprhold_to_date
FROM  
    spriden
    JOIN goremal ON spriden_pidm = goremal_pidm
    JOIN sprhold ON spriden_pidm = sprhold_pidm
WHERE
    1=1

    -- SELECT PRIMARY SPRIDEN ID
    AND spriden_change_ind IS NULL

    -- SELECT PRIMARY PERSONAL EMAIL ADDRESS
    AND GOREMAL_EMAL_CODE = 'PERS' AND GOREMAL_PREFERRED_IND = 'Y'

    -- LIMIT TO IN-DATE TIER 4 HOLDS
    AND sprhold_hldd_code = 'V1'
    AND SYSDATE BETWEEN sprhold_from_date AND sprhold_to_date