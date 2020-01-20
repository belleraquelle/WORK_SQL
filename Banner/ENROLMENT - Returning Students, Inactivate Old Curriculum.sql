SELECT
    spriden_id AS "ID",
    cur1.sorlcur_term_code AS "Old_Curriculum_Record_Term",
    cur1.sorlcur_program AS "Old_Curriculum_Record_Prog",
    sorlfos_csts_code AS "Old_Curriculum_Record_Status",
    cur1.sorlcur_cact_code AS "Old_Curriculum_Record_Activity",
    cur1.sorlcur_priority_no AS "Old_Curriculum_Record_Priority",
    cur1.sorlcur_end_date,
    cur2.sorlcur_term_code AS "New_Curriculum_Record_Term",
    cur2.sorlcur_program AS "New_Curriculum_Record_Prog",
    cur2.sorlcur_priority_no AS "New_Curriculum_Record_Priority"
    
FROM
    sorlcur cur1
    JOIN sorlcur cur2 ON cur1.sorlcur_pidm = cur2.sorlcur_pidm
    JOIN spriden ON cur1.sorlcur_pidm = spriden_pidm
    JOIN sorlfos ON sorlfos_pidm = cur1.sorlcur_pidm AND cur1.sorlcur_seqno = sorlfos_lcur_seqno

WHERE
    1=1

    -- Primary BannerID
    AND spriden_change_ind IS NULL

    -- Old curriculum parameters
    AND cur1.sorlcur_lmod_code = 'LEARNER'
    AND cur1.sorlcur_end_date < SYSDATE
    AND cur1.sorlcur_term_code_end IS NULL
    AND cur1.sorlcur_current_cde = 'Y'
    AND cur1.sorlcur_cact_code != 'INACTIVE'
    AND cur1.sorlcur_priority_no NOT LIKE '99%' -- This takes out the migrated 999 records that we might want to tidy later
    
    -- New curriculum parameters
    AND cur2.sorlcur_lmod_code = 'LEARNER'
    AND cur2.sorlcur_end_date > SYSDATE
    AND cur2.sorlcur_term_code_admit = '202001'
    AND cur2.sorlcur_term_code_end IS NULL
    AND cur2.sorlcur_current_cde = 'Y'

    -- Only return where the sorlcur_term_codes are not the same
    AND cur1.sorlcur_term_code != cur2.sorlcur_term_code

ORDER BY
      ID
;