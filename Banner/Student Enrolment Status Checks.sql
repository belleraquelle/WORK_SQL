/*
This query will return students with inconsistencies in their enrolment statuses.
*/

SELECT DISTINCT
    spriden_id AS "Student_Number", 
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    sorlcur_key_seqno AS "Curriculum_Study_Path",
    --sorlcur_lmod_code,
    sorlcur_term_code_admit AS "Curriculum_Admit_Term",
    sorlcur_program AS "Programme",
    sorlcur_start_date AS "Curriculum_Start_Date",
    sorlcur_end_date AS "Expected_Completion_Date",
    sorlcur_styp_code AS "Mode_of_Study",
    sorlcur_camp_code AS "Campus",
    b1.sfrensp_key_seqno AS "Study_Path",
    a1.sfbetrm_term_code AS "Term_1",
    a1.sfbetrm_ests_code AS "Term_1_Enrolment_Status",
    b1.sfrensp_ests_code AS "T1_Study_Path_Enrolment_Status",
    
    
    a2.sfbetrm_term_code AS "Term_2",
    a2.sfbetrm_ests_code AS "Term_2_Enrolment_Status",
    b2.sfrensp_ests_code AS "T2_Study_Path_Enrolment_Status",
    
    a3.sfbetrm_term_code AS "Term_3",
    a3.sfbetrm_ests_code AS "Term_3_Enrolment_Status",
    b3.sfrensp_ests_code AS "T3_Study_Path_Enrolment_Status",
    
    sgrsatt_atts_code AS "Student_Attribute",
    sgrchrt_chrt_code AS "Student_Cohort"

FROM
    sgbstdn
    JOIN spriden ON sgbstdn_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sorlcur t1 ON sgbstdn_pidm = sorlcur_pidm
    JOIN sfbetrm a1 ON sgbstdn_pidm = a1.sfbetrm_pidm AND a1.sfbetrm_term_code = '201909'
    LEFT JOIN sfbetrm a2 ON sgbstdn_pidm = a2.sfbetrm_pidm AND a2.sfbetrm_term_code = '202001'
    LEFT JOIN sfbetrm a3 ON sgbstdn_pidm = a3.sfbetrm_pidm AND a3.sfbetrm_term_code = '202006'
    JOIN sfrensp b1 ON sgbstdn_pidm = b1.sfrensp_pidm AND sorlcur_key_seqno = b1.sfrensp_key_seqno AND b1.sfrensp_term_code = '201909'
    LEFT JOIN sfrensp b2 ON sgbstdn_pidm = b2.sfrensp_pidm AND sorlcur_key_seqno = b2.sfrensp_key_seqno AND b2.sfrensp_term_code = '202001'
    LEFT JOIN sfrensp b3 ON sgbstdn_pidm = b3.sfrensp_pidm AND sorlcur_key_seqno = b3.sfrensp_key_seqno AND b3.sfrensp_term_code = '202006'
    JOIN sgrstsp s1 ON sorlcur_pidm = sgrstsp_pidm AND sorlcur_key_seqno = sgrstsp_key_seqno
    LEFT JOIN sgrsatt ON sgrsatt_pidm = sorlcur_pidm AND sgrsatt_stsp_key_sequence = sorlcur_key_seqno AND sgrsatt_term_code_eff = sorlcur_term_code_admit
    LEFT JOIN sgrchrt ON sgrchrt_pidm = sorlcur_pidm AND sgrchrt_stsp_key_sequence = sorlcur_key_seqno AND sgrchrt_term_code_eff = sorlcur_term_code_admit

WHERE
    1=1

    --Limit to current students
    AND sgbstdn_STST_CODE = 'AS'

    --Select maximum term sorlcur record for each study path and limit to those with future end dates
    AND t1.sorlcur_term_code = (
        SELECT MAX(t2.sorlcur_term_code)
        FROM sorlcur t2
        WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER')
    AND t1.sorlcur_current_cde = 'Y'
    AND t1.sorlcur_end_date > sysdate
    AND t1.sorlcur_cact_code = 'ACTIVE'
    AND t1.sorlcur_lmod_code = 'LEARNER'

    -- Limit to current SPRIDEN_ID
    AND spriden_change_ind IS NULL

    -- Limit to active study paths
    AND s1.sgrstsp_term_code_eff = (
        SELECT MAX(s2.sgrstsp_term_code_eff)
        FROM sgrstsp s2
        WHERE s2.sgrstsp_pidm = s1.sgrstsp_pidm AND s2.sgrstsp_key_seqno = s1.sgrstsp_key_seqno)
    AND s1.sgrstsp_stsp_code = 'AS'

    -- Check for mismatched / missing status codes
    AND a1.sfbetrm_ests_code = 'EN'
    AND (
        -- Completion date beyond December but S2 status not set
        (sorlcur_end_date > '31-DEC-19' AND a2.sfbetrm_ests_code NOT IN ('EN', 'AT') AND sorlcur_start_date NOT LIKE '%JAN%' AND sorlcur_start_date NOT LIKE '%MAR%')
        -- Completion date beyond May but S3 status not set
        OR (sorlcur_end_date > '31-MAY-20' AND a3.sfbetrm_ests_code NOT IN ('EN', 'AT') AND sorlcur_start_date NOT LIKE '%JAN%' AND sorlcur_start_date NOT LIKE '%MAR%')
        -- S1: Overall enrolment status and study path status don't match
        OR (a1.sfbetrm_ests_code != b1.sfrensp_ests_code)
        -- S2: Overall enrolment status and study path status don't match
        OR (a2.sfbetrm_ests_code != b2.sfrensp_ests_code)
        -- S3: Overall enrolment status and study path status don't match
        OR (a3.sfbetrm_ests_code != b3.sfrensp_ests_code)
    )
    
    --AND spriden_id = '19018639'

ORDER BY
      spriden_last_name || ', ' || spriden_first_name
      
;