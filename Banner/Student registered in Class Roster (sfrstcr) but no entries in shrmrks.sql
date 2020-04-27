SELECT
    sfrstcr_crn,
    sfrstcr_term_code,
    spriden_id, 
    sfrstcr_pidm, 
    sfrstcr_rsts_code, 
    shrmrks.*
FROM
    sfrstcr
    JOIN spriden ON sfrstcr_pidm = spriden_pidm
    LEFT JOIN shrmrks ON shrmrks_term_code = sfrstcr_term_code AND shrmrks_crn = sfrstcr_crn AND shrmrks_pidm = sfrstcr_pidm
WHERE
    1=1
    AND sfrstcr_rsts_code IN ('RE', 'RW')
    AND shrmrks_gcom_id IS NULL
    AND sfrstcr_crn||sfrstcr_term_code IN (SELECT DISTINCT shrgcom_crn||shrgcom_term_code FROM shrgcom)
ORDER BY
	spriden_id
;