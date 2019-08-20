SELECT DISTINCT
    spriden_id,
    spriden_last_name,
    spriden_first_name,
    sfrstcr_crn
    --sgrsatt.*
FROM 
    sfrstcr
    JOIN spriden ON sfrstcr_pidm = spriden_pidm
    LEFT JOIN sgrsatt ON sgrsatt_pidm = spriden_pidm
WHERE 
    1=1
    -- Select the students from the placement CRN
    AND sfrstcr_crn = 3938 

    -- Exclude redundant / duplicate student numbers
    AND spriden_change_ind IS NULL

    -- Exclude students who already have the SW attribute starting at the same time as the placement module
    AND spriden_pidm NOT IN 
        (
            SELECT sgrsatt_pidm
            FROM sgrsatt
            WHERE sgrsatt_term_code_eff = '201909' AND sgrsatt_atts_code = 'SW'
        )

;
