SELECT DISTINCT
      spriden_id, s1.sorlcur_term_code, s1.sorlcur_program, s2.sorlcur_term_code, s2.sorlcur_program
FROM
    sorlcur s1
    JOIN sorlcur s2 ON s1.sorlcur_pidm = s2.sorlcur_pidm
    --JOIN sorlfos ON sorlcur_pidm = sorlfos_pidm AND sorlfos_lcur_seqno = sorlcur_seqno
    JOIN spriden ON s1.sorlcur_pidm = spriden_pidm
WHERE
     1=1
     AND s1.sorlcur_degc_code = 'FNDIP'
     AND s1.sorlcur_term_code < '201909'
     AND s1.sorlcur_lmod_code = 'LEARNER'
     AND s2.sorlcur_degc_code != 'FNDIP'
     AND s2.sorlcur_term_code = '201909'
     AND s2.sorlcur_lmod_code = 'LEARNER'
     --AND sorlcur_program IN ('PGCEQ', 'FGCEQ')
     --AND sorlfos_majr_code IN ('P3','P5')
     AND spriden_change_ind IS NULL
ORDER BY
      s1.sorlcur_program, s2.sorlcur_program, spriden_id
