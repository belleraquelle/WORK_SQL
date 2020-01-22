SELECT
    spriden_id, shrtckn_pidm, sorlcur_program, shrtckn_stsp_key_sequence, SUM(shrtckg_credit_hours)
FROM
    shrtckn a1
    JOIN shrtckg b1 ON a1.shrtckn_term_code = b1.shrtckg_term_code AND a1.shrtckn_seq_no = b1.shrtckg_tckn_seq_no AND a1.shrtckn_pidm = b1.shrtckg_pidm 
    JOIN spriden c1 ON a1.shrtckn_pidm = c1.spriden_pidm AND c1.spriden_change_ind IS NULL
    JOIN sorlcur d1 ON a1.shrtckn_pidm = d1.sorlcur_pidm AND a1.shrtckn_stsp_key_sequence = d1.sorlcur_key_seqno AND sorlcur_lmod_code = 'LEARNER'
WHERE
    1=1
    AND b1.shrtckg_seq_no = (SELECT(MAX(b2.shrtckg_seq_no) FROM shrtckg_seq_no b2 WHERE 
    AND d1.sorlcur_term_code = (SELECT MAX(d2.sorlcur_term_code) FROM sorlcur d2 WHERE d2.sorlcur_lmod_code = 'LEARNER' AND d1.sorlcur_pidm = d2.sorlcur_pidm AND d1.sorlcur_key_seqno = d2.sorlcur_key_seqno) AND d1.sorlcur_term_code_end IS NULL
    --AND d1.sorlcur_program LIKE 'FNDIP%'
    AND (a1.shrtckn_crse_numb LIKE '5%' OR a1.shrtckn_crse_numb LIKE '6%')
    AND b1.shrtckg_grde_code_final != 'DR'
    AND shrtckn_pidm IN (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = '202001_SILVER' AND glbextr_user_id = 'BANSECR_SCLARKE')

GROUP BY
    spriden_id,
    shrtckn_pidm,
    sorlcur_program,
    shrtckn_stsp_key_sequence
HAVING
    SUM(shrtckg_credit_hours) >= 330
ORDER BY
    d1.sorlcur_program
;