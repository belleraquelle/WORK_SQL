SELECT
      spriden_id, sorlcur.*
FROM
    sorlcur
    JOIN spriden ON sorlcur_pidm = spriden_pidm
WHERE
     1=1
     AND sorlcur_term_code_admit = '201909'
     AND sorlcur_program LIKE 'BENGH-LN'
     --AND sorlcur_styp_code = 'P'
     AND spriden_change_ind IS NULL
