SELECT
      spriden_id, sorlcur.*
FROM
    sorlcur
    JOIN spriden on sorlcur_pidm = spriden_pidm
WHERE
     sorlcur_term_code_admit = '201909'
     AND spriden_change_ind IS NULL
     AND sorlcur_pidm NOT IN
         (SELECT sgbstdn_pidm FROM sgbstdn WHERE sgbstdn_term_code_eff = '201909')