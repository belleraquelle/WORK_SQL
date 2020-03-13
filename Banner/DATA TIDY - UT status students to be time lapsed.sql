SELECT
    spriden1.spriden_id,
    
    -- Min term with UT status
    sfrensp1.sfrensp_term_code AS "MinUnapprovedTerm", 
    sfrensp1.sfrensp_ests_code AS "MinUnapprovedStatus",
    
    -- Max term with UT status
    sfrensp2.sfrensp_term_code AS "MaxUnapprovedTerm",
    sfrensp2.sfrensp_ests_code AS "MaxUnapprovedStatus",
    
    -- Current term enrolment status
    sfrensp3.sfrensp_ests_code AS "CurrentEnrolmentStatus",
    
    -- Course of Study and Expected completion date
    sorlcur1.sorlcur_program AS "CourseOfStudy",
    sorlcur1.sorlcur_end_date AS "ExpectedCompletionDate"
    
FROM
    spriden spriden1
    
    JOIN sfrensp sfrensp1 
        ON sfrensp1.sfrensp_pidm = spriden1.spriden_pidm
        AND sfrensp1.sfrensp_term_code = (SELECT MIN (sfrensp1a.sfrensp_term_code) FROM sfrensp sfrensp1a WHERE sfrensp1a.sfrensp_pidm = sfrensp1.sfrensp_pidm AND sfrensp1a.sfrensp_key_seqno = sfrensp1.sfrensp_key_seqno AND sfrensp1a.sfrensp_ests_code = 'UT')
    
    JOIN sfrensp sfrensp2
        ON sfrensp2.sfrensp_pidm = spriden1.spriden_pidm
        AND sfrensp1.sfrensp_key_seqno = sfrensp2.sfrensp_key_seqno
        AND sfrensp2.sfrensp_term_code = (SELECT MAX (sfrensp2a.sfrensp_term_code) FROM sfrensp sfrensp2a WHERE sfrensp2a.sfrensp_pidm = sfrensp2.sfrensp_pidm AND sfrensp2a.sfrensp_key_seqno = sfrensp2.sfrensp_key_seqno AND sfrensp2a.sfrensp_ests_code = 'UT')
    
    JOIN sfrensp sfrensp3
        ON sfrensp3.sfrensp_pidm = spriden1.spriden_pidm
        AND sfrensp1.sfrensp_key_seqno = sfrensp3.sfrensp_key_seqno
        AND sfrensp3.sfrensp_term_code = 202001
    
    JOIN sorlcur sorlcur1
        ON sfrensp1.sfrensp_pidm = sorlcur1.sorlcur_pidm
        AND sfrensp1.sfrensp_key_seqno = sorlcur1.sorlcur_key_seqno
        AND sorlcur1.sorlcur_lmod_code = 'LEARNER'
        AND sorlcur1.sorlcur_cact_code = 'ACTIVE'
        AND sorlcur1.sorlcur_current_cde = 'Y'
        AND sorlcur1.sorlcur_term_code = (SELECT MAX(sorlcur2.sorlcur_term_code) FROM sorlcur sorlcur2 WHERE sorlcur1.sorlcur_pidm = sorlcur2.sorlcur_pidm AND sorlcur1.sorlcur_key_seqno = sorlcur2.sorlcur_key_seqno AND sorlcur1.sorlcur_lmod_code = sorlcur2.sorlcur_lmod_code AND sorlcur1.sorlcur_cact_code = sorlcur2.sorlcur_cact_code AND sorlcur1.sorlcur_current_cde = sorlcur2.sorlcur_current_cde)
    
WHERE
    1=1
    AND spriden1.spriden_change_ind IS NULL
    AND sfrensp3.sfrensp_ests_code NOT IN ('WD', 'EN', 'AT')
    AND sfrensp2.sfrensp_term_code <= '202001'
    --AND sorlcur1.sorlcur_end_date > '31-MAY-20'
;