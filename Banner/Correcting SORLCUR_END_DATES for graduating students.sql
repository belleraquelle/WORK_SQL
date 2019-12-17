/*

This query pulls through the 'current' Learner and Outcome SORLCUR records for a 
Study Path with an award dated within the data range. These can then be checked for

1. Consistency with each other
2. For dates beyond the award date
3. Null values

*/


SELECT 
    spriden_id,
    shrdgmr_pidm, 
    t1.sorlcur_seqno, 
    t1.sorlcur_term_code,
    t1.sorlcur_lmod_code, 
    t1.sorlcur_end_date,
    o1.sorlcur_seqno,
    o1.sorlcur_lmod_code, 
    o1.sorlcur_end_Date,
    shrdgmr_degs_code, 
    shrdgmr_grad_date,
    shrdgmr_activity_date
FROM
    shrdgmr
    JOIN sorlcur t1 ON shrdgmr_pidm = t1.sorlcur_pidm AND shrdgmr_stsp_key_sequence = t1.sorlcur_key_seqno
    JOIN sorlcur o1 ON shrdgmr_pidm = o1.sorlcur_pidm AND shrdgmr_seq_no = o1.sorlcur_key_seqno 
    JOIN spriden ON shrdgmr_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE 
    1=1
    AND shrdgmr_grad_date BETWEEN '01-DEC-19' AND '16-DEC-19' 
    AND shrdgmr_degs_code = 'AW'
    AND t1.sorlcur_term_code = (
                SELECT MAX(t2.sorlcur_term_code)
                FROM sorlcur t2
                WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER')
    AND t1.sorlcur_lmod_code = 'LEARNER'
    AND t1.sorlcur_cact_code = 'ACTIVE'
    AND t1.sorlcur_current_cde = 'Y'
    
    AND o1.sorlcur_seqno = (
                SELECT MAX(o2.sorlcur_seqno)
                FROM sorlcur o2
                WHERE o2.sorlcur_pidm = o1.sorlcur_pidm AND o2.sorlcur_key_seqno = o1.sorlcur_key_seqno AND o2.sorlcur_lmod_code = 'OUTCOME')
    AND o1.sorlcur_lmod_code = 'OUTCOME'
   
    --AND t1.sorlcur_end_date != o1.sorlcur_end_date
    --AND o1.sorlcur_end_date > shrdgmr_grad_date AND NOT (t1.sorlcur_end_date != o1.sorlcur_end_date)
    --AND t1.sorlcur_end_date > shrdgmr_grad_date AND NOT (t1.sorlcur_end_date != o1.sorlcur_end_date)
    --AND (o1.sorlcur_end_date IS NULL OR t1.sorlcur_end_date IS NULL)
    
    --AND shrdgmr_pidm = 1317792
;