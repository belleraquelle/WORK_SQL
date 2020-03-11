SELECT
    spriden1.spriden_id,
    
    -- Min term with UT status
    sfrensp1.sfrensp_term_code AS "MinUnapprovedTerm", 
    sfrensp1.sfrensp_ests_code AS "MinUnapprovedStatus",
    
    -- Max term with UT status
    sfrensp2.sfrensp_term_code AS "MaxUnapprovedTerm",
    sfrensp2.sfrensp_ests_code AS "MaxUnapprovedStatus",
    
    -- Current term enrolment status
    sfrensp3.sfrensp_ests_code AS "CurrentEnrolmentStatus"
    
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
    
WHERE
    1=1
    AND spriden1.spriden_change_ind IS NULL
    AND sfrensp3.sfrensp_ests_code NOT IN ('WD', 'EN', 'AT')
    AND sfrensp2.sfrensp_term_code <= '201909'
;