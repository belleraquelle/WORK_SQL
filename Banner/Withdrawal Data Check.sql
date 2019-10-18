SELECT
    sfbetrm_term_code AS "Term Code",
    spriden_id AS "Student Number", 
    sfbetrm_ests_code AS "Overall Enrolment Status", 
    sfbetrm_rgre_code AS "Withdrawal Reason",
    sfbetrm_ests_date AS "Overall Status Date",
    sfrensp_term_code AS "Study Path Term",
    sfrensp_key_seqno AS "Study Path Number", 
    sfrensp_ests_code AS "Study Path Enrolment Status",
    sfrensp_ests_date AS "Study Path Status Date",
    s1.sgrstsp_key_seqno AS "Stuy Path Number",
    s1.sgrstsp_term_code_eff AS "Study Path Term Effective",
    s1.sgrstsp_stsp_code AS "Study Path Number",
    t1.sgbstdn_term_code_eff AS "Learner Record Term Effective",
    t1.sgbstdn_term_code_admit AS "Learner Record Term Code Admit",
    t1.sgbstdn_stst_code AS "Overall Student Status",
    v1.sorlcur_end_date AS "Curriculum Record End Date",
    sorlfos_csts_code AS "Field of Study Status"
FROM
    sfbetrm
    JOIN sfrensp ON sfbetrm_pidm = sfrensp_pidm AND sfbetrm_term_code = sfrensp_term_code
    JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgrstsp s1 ON s1.sgrstsp_pidm = sfrensp_pidm AND s1.sgrstsp_key_seqno = sfrensp_key_seqno
    JOIN sgbstdn t1 ON t1.sgbstdn_pidm = sfbetrm_pidm
    JOIN sorlcur v1 ON v1.sorlcur_pidm = sgrstsp_pidm AND v1.sorlcur_key_seqno = sgrstsp_key_seqno AND sorlcur_lmod_code = 'LEARNER' AND sorlcur_current_cde = 'Y'
    JOIN sorlfos ON sorlfos_pidm = v1.sorlcur_pidm AND sorlfos_lcur_seqno = sorlcur_seqno
WHERE

    1=1
    
    -- Return SFAREGS records with a WD status
    AND (sfbetrm_ests_code = 'WD' OR sfrensp_ests_code = 'WD')
    
    -- Return the MAX term effective study path record for the associated study path
    AND s1.sgrstsp_term_code_eff = (
        SELECT MAX(s2.sgrstsp_term_code_eff)
        FROM sgrstsp s2
        WHERE s2.sgrstsp_pidm = s1.sgrstsp_pidm AND s2.sgrstsp_key_seqno = s1.sgrstsp_key_seqno)
        
    -- Return the MAX term effective learner record for the associated study path
    AND t1.sgbstdn_term_code_eff = (
        SELECT MAX(t2.sgbstdn_term_code_eff)
        FROM sgbstdn t2
        WHERE t2.sgbstdn_pidm = t1.sgbstdn_pidm)
        
    -- Return the MAX term effective sorlcur record for the associated study path
    AND v1.sorlcur_term_code = (
        SELECT MAX(v2.sorlcur_term_code)
        FROM sorlcur v2
        WHERE v2.sorlcur_pidm = v1.sorlcur_pidm AND v2.sorlcur_key_seqno = v1.sorlcur_key_seqno)
    
ORDER BY
    spriden_id
;