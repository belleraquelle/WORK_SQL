SELECT
    spriden_id, sorlcur.*
FROM
    sorlcur
    JOIN spriden ON sorlcur_pidm = spriden_pidm
WHERE
    sorlcur_program IN ('FNDIP-FBE', 'FNDIP-FCO', 'FNDIP-FEG', 'FNDIP-FHU', 'FNDIP-IFA', 'FNDIP-IFB', 'FNDIP-IFP')
    AND sorlcur_lmod_code = 'LEARNER'
    AND sorlcur_term_code != '201909'
    AND sorlcur_term_code_end = '201909'
    AND sorlcur_camp_code = 'OBO'
    AND spriden_change_ind IS NULL
ORDER BY
    sorlcur_program