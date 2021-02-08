/*

This query tries to extract any records where the curriculum end date on the LEARNER record 
doesn't match the curriculum end date on the OUTCOME record and the student has been awarded. 

Some of the stuff currently on this report looks like a possible migration error, but we need to be mindful 
of mismatches here going forward. Re-rolling to outcome just before Exam Committees should remove most of the issues,
but this query could still be useful.

*/

SELECT 
    spriden_id, 
    s1.sorlcur_key_seqno,
    s1.sorlcur_program,
    s1.sorlcur_end_date AS "Learner_End_Date",
    s2.sorlcur_key_seqno,
    s2.sorlcur_end_date AS "Outcome_End_Date",
    shrdgmr_degs_code,
    shrdgmr_grad_date

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
    
    AND s1.sorlcur_end_date != s2.sorlcur_end_date
    
    AND shrdgmr_degs_code = 'AW'
    
    AND shrdgmr_grad_date >= '01-JAN-2020'
    
ORDER BY 
	s1.sorlcur_program
;