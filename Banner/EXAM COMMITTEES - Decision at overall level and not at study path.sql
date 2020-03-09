SELECT
    spriden_id, sgbstdn_program_1, shrttrm_term_code, shrttrm_astd_code_end_of_term, shrapsp_term_code, shrapsp_astd_code_end_of_term
FROM 
    shrttrm
    LEFT JOIN shrapsp ON shrttrm_pidm = shrapsp_pidm AND shrttrm_term_code = shrapsp_term_code
    JOIN spriden ON shrttrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgbstdn a1 ON shrttrm_pidm = sgbstdn_pidm AND a1.sgbstdn_term_code_eff = (SELECT MAX(a2.sgbstdn_term_code_eff) FROM sgbstdn a2 WHERE a1.sgbstdn_pidm = a2.sgbstdn_pidm)
WHERE
    shrttrm_astd_code_end_of_term IS NOT NULL AND shrttrm_activity_date >= '01-JAN-20' AND shrapsp_astd_code_end_of_term IS NULL