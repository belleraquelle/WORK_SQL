SELECT
    spriden_id, spriden_last_name, spriden_first_name, sorlcur_program
    
FROM
    sorlcur t1
    JOIN sgrstsp s1 ON t1.sorlcur_pidm = s1.sgrstsp_pidm AND t1.sorlcur_key_seqno = s1.sgrstsp_key_seqno
    JOIN spriden ON t1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE

    1=1
    AND t1.sorlcur_program IN ('CRTFN-UEL1', 'CRTFN-UEL2', 'CRTUG-UEL3')
    AND t1.sorlcur_lmod_code = 'LEARNER'
    AND t1.sorlcur_cact_code = 'ACTIVE'
    AND t1.sorlcur_current_cde = 'Y'
    AND t1.sorlcur_end_date BETWEEN '01-DEC-2019' AND '31-DEC-2019'
    
    AND t1.sorlcur_term_code = (
        SELECT MAX(t2.sorlcur_term_code)
        FROM sorlcur t2
        WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER')
        
    AND s1.sgrstsp_term_code_eff = (
        SELECT MAX(s2.sgrstsp_term_code_eff)
        FROM sgrstsp s2
        WHERE s2.sgrstsp_pidm = s1.sgrstsp_pidm AND s2.sgrstsp_key_seqno = s1.sgrstsp_key_seqno)
    AND s1.sgrstsp_stsp_code = 'AS'
;


SELECT * FROM sgrstsp;