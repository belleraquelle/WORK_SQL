SELECT
    spriden_id, sorlcur_end_date, sorlcur_program, sorlcur_styp_code
FROM 
    sorlcur
    JOIN spriden on sorlcur_pidm = spriden_pidm and spriden_change_ind is null
WHERE
    sorlcur_program like 'BSCH-HCN%'
    AND sorlcur_term_code_admit = '201909'
    AND sorlcur_lmod_code = 'LEARNER'
    AND sorlcur.sorlcur_current_cde = 'Y'
;