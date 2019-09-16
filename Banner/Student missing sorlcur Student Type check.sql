-- By admit term    
SELECT
    spriden_id, sorlcur.*
FROM
    sorlcur
    JOIN spriden on sorlcur_pidm = spriden_pidm
WHERE
    1=1
    AND sorlcur_term_code_admit = '201909'
    AND sorlcur_styp_code IS NULL
    AND sorlcur_current_cde = 'Y'
    AND spriden_change_ind IS NULL
;


-- Any true record with an end date in the future
SELECT
    spriden_id, sorlcur.*
FROM
    sorlcur
    JOIN spriden on sorlcur_pidm = spriden_pidm
WHERE
    1=1
    --AND sorlcur_term_code_admit = '201909'
    AND sorlcur_styp_code IS NULL
    AND sorlcur_current_cde = 'Y'
    AND spriden_change_ind IS NULL
    AND sorlcur_lmod_code = 'LEARNER'
    AND sorlcur_end_date > sysdate
;