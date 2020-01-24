SELECT DISTINCT
    spriden_id AS "Student_ID",
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    s2.sorlcur_program AS "Original_Award",
    s1.sorlcur_program AS "Exit_Award", 
    shrdgih_honr_code AS "Classification"   
FROM 
    sorlcur s1
    JOIN shrdgmr ON s1.sorlcur_pidm = shrdgmr_pidm AND s1.sorlcur_key_seqno = shrdgmr_seq_no
    JOIN spriden ON s1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN shrdgih ON shrdgmr_pidm = shrdgih_pidm AND shrdgmr_seq_no = shrdgih_dgmr_seq_no
    JOIN sorlcur s2 ON s1.sorlcur_pidm = s2.sorlcur_pidm AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno AND s2.sorlcur_lmod_code = 'LEARNER'
        AND s2.sorlcur_term_code = (SELECT MAX(s3.sorlcur_term_code) FROM sorlcur s3 WHERE s2.sorlcur_pidm = s3.sorlcur_pidm AND s2.sorlcur_key_seqno = s3.sorlcur_key_seqno AND s2.sorlcur_lmod_code = s3.sorlcur_lmod_code AND s3.sorlcur_program NOT IN ('CHEU','DHEU'))
WHERE 
    1=1 
    AND s1.sorlcur_lmod_code = 'OUTCOME' 
    AND s1.sorlcur_current_cde = 'Y'
    --(SELECT MAX(s2.sorlcur_term_code) FROM sorlcur s2 WHERE s1.sorlcur_pidm = s2.sorlcur_pidm AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno AND s1.sorlcur_lmod_code = s2.sorlcur_lmod_code)
    AND s1.sorlcur_program IN ('CHEU','DHEU')
    AND shrdgmr_degs_code = 'PN'
ORDER BY
    "Original_Award",
    spriden_id
;