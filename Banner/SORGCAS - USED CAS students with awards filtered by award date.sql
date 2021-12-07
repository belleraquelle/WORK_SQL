SELECT 
    spriden_id,
    shrdgmr.*,
    skricas.*
FROM 
    skricas
    JOIN spriden ON spriden_pidm = skricas_pidm AND spriden_change_ind IS NULL
    JOIN sorlcur learnerSorlcur ON skricas_pidm = learnerSorlcur.sorlcur_pidm 
        AND learnerSorlcur.sorlcur_seqno = skricas_lcur_seqno AND learnerSorlcur.sorlcur_lmod_code = 'LEARNER' AND learnerSorlcur.sorlcur_term_code_end IS NULL
    JOIN shrdgmr ON learnerSorlcur.sorlcur_pidm = shrdgmr_pidm AND learnerSorlcur.sorlcur_key_seqno = shrdgmr_stsp_key_sequence 
    JOIN sorlcur outcomeSorlcur ON shrdgmr_pidm = outcomeSorlcur.sorlcur_pidm AND shrdgmr_seq_no = outcomeSorlcur.sorlcur_key_seqno
        AND outcomeSorlcur.sorlcur_lmod_code = 'OUTCOME' AND outcomeSorlcur.sorlcur_term_code_end IS NULL
WHERE
    1=1
    AND shrdgmr_degs_code = 'AW'
    AND shrdgmr_grad_date >= '01-AUG-2021'
    AND skricas_cas_status = 'USED'
    --AND skricas_pidm = '1325204';