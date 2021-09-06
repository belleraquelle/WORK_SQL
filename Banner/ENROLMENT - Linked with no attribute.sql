SELECT DISTINCT
    spriden_id, sorlcur_key_seqno, sgrsatt.*
FROM
    sorlcur
    JOIN spriden ON sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
    LEFT JOIN sgrsatt ON sorlcur_pidm = sgrsatt_pidm AND sorlcur_key_seqno = sgrsatt_stsp_key_sequence AND sgrsatt_term_code_eff = sorlcur_term_code_admit
WHERE
    sorlcur_term_code_admit = '202109'
    AND sorlcur_lmod_code = 'LEARNER'
    AND sgrsatt_atts_code IS NULL
;