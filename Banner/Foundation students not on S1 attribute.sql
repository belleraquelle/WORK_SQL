SELECT
      spriden_id, sgrsatt_atts_code, s1.*
FROM
    sorlcur s1
    JOIN spriden ON s1.sorlcur_pidm = spriden_pidm
    JOIN sgrsatt ON s1.sorlcur_pidm = sgrsatt_pidm AND s1.sorlcur_key_seqno = sgrsatt_stsp_key_sequence
WHERE
     1=1
     --AND sorlcur_term_code_admit = '201909'
     AND s1.sorlcur_term_code = (
         SELECT MAX(s2.sorlcur_term_code)
         FROM sorlcur s2
         WHERE s2.sorlcur_pidm = s1.sorlcur_pidm)
     AND sgrsatt_term_code_eff = '201909'
     AND sorlcur_program LIKE 'FNDI%'
     AND sgrsatt_atts_code != 'S1'
     --AND sorlcur_styp_code = 'P'
     AND spriden_change_ind IS NULL
     AND sorlcur_current_cde = 'Y'
     AND sorlcur_lmod_code = 'LEARNER'
     AND sorlcur_cact_code = 'ACTIVE'
;