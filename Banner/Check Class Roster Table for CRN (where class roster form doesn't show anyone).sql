SELECT 
    spriden_id 
FROM 
    sfrstcr
    JOIN spriden ON sfrstcr_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE 
    sfrstcr_crn = 3992 
    AND sfrstcr_term_code = '201909'
;