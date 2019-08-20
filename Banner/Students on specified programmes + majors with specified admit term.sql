SELECT
      spriden_id, sorlcur.*, sorlfos.*
FROM
    sorlcur
    JOIN sorlfos ON sorlcur_pidm = sorlfos_pidm AND sorlfos_lcur_seqno = sorlcur_seqno
    JOIN spriden ON sorlcur_pidm = spriden_pidm
WHERE
     1=1
     AND sorlcur_term_code_admit = '201909'
     AND sorlcur_program IN ('PGCEQ', 'FGCEQ')
     AND sorlfos_majr_code IN ('P3','P5')
     AND spriden_change_ind IS NULL
