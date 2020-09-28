/*

This query identifies students who have been awarded on a study path, but who appear to still have an end date in the future. 
Any students on this report will need to have their end dates updated appropriately.

*/

SELECT 
    spriden_id, 
    s1.sorlcur_key_seqno,
    CASE
    	WHEN s1.sorlcur_end_date > sysdate AND s2.sorlcur_end_date > sysdate THEN 'Both end dates in future'
    	WHEN s1.sorlcur_end_date > sysdate THEN 'Learner end date is in the future'
    	ELSE 'Outcome end date is in the future'
    END AS "Issue",
    s1.sorlcur_program,
    s1.sorlcur_end_date AS "Learner_End_Date",
    s2.sorlcur_key_seqno,
    s2.sorlcur_end_date AS "Outcome_End_Date",
    shrdgmr_degs_code,
    shrdgmr_grad_date AS "Award_Date"

FROM
    sorlcur s1
    JOIN spriden ON s1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN shrdgmr ON s1.sorlcur_pidm = shrdgmr_pidm AND s1.sorlcur_key_seqno = shrdgmr_stsp_key_sequence
    JOIN sorlcur s2 ON shrdgmr_pidm = s2.sorlcur_pidm AND shrdgmr_seq_no = s2.sorlcur_key_seqno
    
WHERE
    
    1=1

    AND s1.sorlcur_lmod_code = 'LEARNER'
    AND s1.sorlcur_cact_code = 'ACTIVE' AND s1.sorlcur_current_cde = 'Y'
    AND s1.sorlcur_term_code = (
        SELECT MAX(t1.sorlcur_term_code)
        FROM sorlcur t1
        WHERE t1.sorlcur_pidm = s1.sorlcur_pidm AND t1.sorlcur_key_seqno = s1.sorlcur_key_seqno AND t1.sorlcur_lmod_code = 'LEARNER' AND t1.sorlcur_cact_code = 'ACTIVE' AND t1.sorlcur_current_cde = 'Y')
    
    AND s2.sorlcur_lmod_code = 'OUTCOME'
    AND s2.sorlcur_cact_code = 'ACTIVE' AND s2.sorlcur_current_cde = 'Y'
    AND s2.sorlcur_term_code = (
        SELECT MAX(t2.sorlcur_term_code)
        FROM sorlcur t2
        WHERE t2.sorlcur_pidm = s2.sorlcur_pidm AND t2.sorlcur_key_seqno = s2.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'OUTCOME' AND t2.sorlcur_cact_code = 'ACTIVE' AND t2.sorlcur_current_cde = 'Y')
    
    AND (s1.sorlcur_end_date > sysdate OR s2.sorlcur_end_date > sysdate)
    
    AND shrdgmr_degs_code = 'AW'
    
;