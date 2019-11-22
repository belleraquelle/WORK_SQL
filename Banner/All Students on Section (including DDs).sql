SELECT
    spriden_id, 
    sfrstcr.*
FROM
    sfrstcr
    JOIN spriden ON sfrstcr_pidm = spriden_pidm
WHERE
    1=1
    AND sfrstcr_term_code = 201909
    AND sfrstcr_crn = 3001
;