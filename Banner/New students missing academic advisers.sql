SELECT DISTINCT
    spriden_id, spriden_last_name, spriden_first_name, sorlcur_term_code_admit, sorlcur_program, sgradvr.*
FROM
    sorlcur
    LEFT JOIN sgradvr ON sorlcur_pidm = sgradvr_pidm
    JOIN spriden ON sorlcur_pidm = spriden_pidm
WHERE
    1=1
    AND sorlcur_term_code_admit = '201909'
    AND sorlcur_lmod_code = 'LEARNER'
    AND spriden_change_ind IS NULL
    AND sgradvr_advr_code IS NULL
    AND sorlcur_current_cde = 'Y'
ORDER BY 
    sorlcur_program,
    spriden_last_name,
    spriden_first_name
;