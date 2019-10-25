/*
This query will return students with the specified ADMIT TERM who have an OP status on the academic enrolment SDE AND who have an overall
enrolment status for the term of EL. This indicates that 1) they haven't engaged with online enrolment and 2) they haven't been 'enrolled'
*/

SELECT DISTINCT
    spriden_id, 
    spriden_last_name || ', ' || spriden_first_name AS "StudentName",
    sorlcur_key_seqno,
    sorlcur_term_code_admit,
    sorlcur_program,
    sorlcur_start_date,
    sorlcur_end_date,
    sorlcur_styp_code,
    sorlcur_camp_code,
    a.gorsdav_value.accessVARCHAR2() as "AcEnrol",
    b.gorsdav_value.accessVARCHAR2() as "FinEnrol",
    c.gorsdav_value.accessVARCHAR2() as "OverallEnrol",
    sfbetrm_ests_code,
    sfrensp_key_seqno,
    sfrensp_ests_code,
    s1.sgrstsp_stsp_code,
    sgrsatt_atts_code,
    sgrchrt_chrt_code
FROM
    sgbstdn
    JOIN spriden ON sgbstdn_pidm = spriden_pidm AND spriden_change_ind IS NULL
    LEFT JOIN gorsdav a ON a.gorsdav_table_name = 'SGBSTDN'
        AND a.gorsdav_attr_name = 'ACENROL_STATUS'
        AND a.gorsdav_PK_PARENTTAB=sgbstdn_PIDM||CHR(1)||sgbstdn_TERM_CODE_EFF
    LEFT JOIN gorsdav b ON b.gorsdav_table_name = 'SGBSTDN'
        AND b.gorsdav_attr_name = 'FINENROL_STATUS'
        AND b.gorsdav_PK_PARENTTAB=sgbstdn_PIDM||CHR(1)||sgbstdn_TERM_CODE_EFF
    LEFT JOIN gorsdav c ON c.gorsdav_table_name = 'SGBSTDN'
        AND c.gorsdav_attr_name = 'OVERALL_ENROL_STATUS'
        AND c.gorsdav_PK_PARENTTAB=sgbstdn_PIDM||CHR(1)||sgbstdn_TERM_CODE_EFF
    JOIN sorlcur t1 ON sgbstdn_pidm = sorlcur_pidm
    JOIN sfbetrm ON sgbstdn_pidm = sfbetrm_pidm
    JOIN sfrensp ON sgbstdn_pidm = sfrensp_pidm AND sorlcur_key_seqno = sfrensp_key_seqno
    JOIN sgrstsp s1 ON sorlcur_pidm = sgrstsp_pidm AND sorlcur_key_seqno = sgrstsp_key_seqno
    LEFT JOIN sgrsatt ON sgrsatt_pidm = sorlcur_pidm AND sgrsatt_stsp_key_sequence = sorlcur_key_seqno AND sgrsatt_term_code_eff = sorlcur_term_code_admit
    LEFT JOIN sgrchrt ON sgrchrt_pidm = sorlcur_pidm AND sgrchrt_stsp_key_sequence = sorlcur_key_seqno AND sgrchrt_term_code_eff = sorlcur_term_code_admit
WHERE
    1=1
    
    --Limit to current students
    AND sgbstdn_STST_CODE = 'AS'
    
    --Limit to students who have completed online enrolment ***This will need adapting in future to look at max sgbstdn record for the statuses***
--    AND (a.gorsdav_VALUE.accessVARCHAR2() = 'CO'
--        AND b.gorsdav_VALUE.accessVARCHAR2() = 'CO'
--        AND c.gorsdav_VALUE.accessVARCHAR2() IN ('CP','CO','OK'))
        
    --Limit to specific enrolment terms
    AND sfbetrm_term_code = '201909'
    AND sfrensp_term_code = '201909'

    --Select maximum term sorlcur record for each study path and limit to those with future end dates
    AND t1.sorlcur_lmod_code = 'LEARNER'
    AND t1.sorlcur_term_code = (
        SELECT MAX(t2.sorlcur_term_code)
        FROM sorlcur t2
        WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno)
    AND t1.sorlcur_current_cde = 'Y'
    AND t1.sorlcur_end_date > sysdate
    AND t1.sorlcur_cact_code = 'ACTIVE'
    
    -- Limit to current SPRIDEN_ID
    AND spriden_change_ind IS NULL
    
    -- Limit to active study paths
    AND s1.sgrstsp_term_code_eff = (
        SELECT MAX(s2.sgrstsp_term_code_eff)
        FROM sgrstsp s2
        WHERE s2.sgrstsp_pidm = s1.sgrstsp_pidm AND s2.sgrstsp_key_seqno = s1.sgrstsp_key_seqno)
    AND s1.sgrstsp_stsp_code = 'AS'
    
    -- Limit to new students with an overall status of EL and an academic enrolment SDE of OP
    AND sorlcur_term_code_admit = '201909'
    AND sfbetrm_ests_code = 'EL'
    AND a.gorsdav_value.accessVARCHAR2() = 'OP'
    
ORDER BY
      spriden_last_name || ', ' || spriden_first_name
;
