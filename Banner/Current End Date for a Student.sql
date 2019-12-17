SELECT 
    spriden_id, t1.sorlcur_end_date
FROM 
    sorlcur t1
    JOIN spriden ON t1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
    1=1
    
    AND spriden_id = '17001921' 
    AND t1.sorlcur_lmod_code = 'LEARNER'
    AND t1.sorlcur_current_cde = 'Y'
    AND t1.sorlcur_cact_code = 'ACTIVE'

    -- Return max term record for the curricula
    AND t1.sorlcur_term_code = (
                SELECT MAX(t2.sorlcur_term_code)
                FROM sorlcur t2
                WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER')
    
    -- Return the record with the priority closest to 1
    AND t1.sorlcur_priority_no = (
        SELECT MIN(t3.sorlcur_priority_no)
        FROM sorlcur t3
        WHERE 
            1=1
            AND t3.sorlcur_pidm = t1.sorlcur_pidm 
            AND t3.sorlcur_key_seqno = t1.sorlcur_key_seqno 
            AND t3.sorlcur_lmod_code = 'LEARNER'
            AND t1.sorlcur_term_code = (
                SELECT MAX(t2.sorlcur_term_code)
                FROM sorlcur t2
                WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER'
                )
        )
;