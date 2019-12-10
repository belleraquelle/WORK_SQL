/*

Extracts students with on ACP campus codes who have an NS status against
the specified term.

*/

SELECT DISTINCT
    spriden_id,
    spriden_last_name, 
    spriden_first_name,
    sorlcur_camp_code,
    sorlcur_program,
    sorlcur_key_seqno,
    sfbetrm.*
    
FROM
    sfbetrm
    JOIN sorlcur t1 ON sfbetrm_pidm = t1.sorlcur_pidm
    JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
    
WHERE
    1=1
    
    AND sfbetrm_term_code = '201909'
    
    AND sfbetrm_ests_code = 'NS'
    
    AND t1.sorlcur_term_code = (
        SELECT MAX(t2.sorlcur_term_code)
        FROM sorlcur t2
        WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER')
    AND t1.sorlcur_current_cde = 'Y'
    AND t1.sorlcur_cact_code = 'ACTIVE'
    
    AND sorlcur_camp_code NOT IN ('OBO', 'DL', 'IPC', 'OBS', 'AIE', 'HKM')

ORDER BY
    sorlcur_camp_code, sorlcur_program, spriden_id

;