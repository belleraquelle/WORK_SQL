SELECT DISTINCT
    spriden_id, sfbetrm_term_code, sfbetrm_ests_code, sorlcur.*
FROM
    sorlcur
    JOIN spriden ON sorlcur_pidm = spriden_pidm
    JOIN sfbetrm ON sorlcur_pidm = sfbetrm_pidm AND sfbetrm_term_code = '201909'
WHERE
    sorlcur_start_date > '21-SEP-19'
    AND sorlcur_lmod_code = 'LEARNER'
    AND sorlcur_term_code_admit = '201909'
    AND spriden_change_ind IS NULL
    AND sfbetrm_ests_code = 'EN'
    AND sorlcur_current_cde = 'Y'
    AND sorlcur_cact_code = 'ACTIVE'
;