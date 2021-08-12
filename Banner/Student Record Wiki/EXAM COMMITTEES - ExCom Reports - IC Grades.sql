SELECT
    spriden_id AS "Student_Number",
    spriden_first_name ||' ' || spriden_last_name AS "Student_Name",
    shrtckn_term_code AS "Term_Code",
    shrtckn_ptrm_code AS "Part_of_Term",
    shrtckn_crn AS "CRN",
    shrtckn_subj_code AS "Subject",
    shrtckn_crse_numb AS "Course_Number",
    shrtckn_crse_title AS "Module_Title",
    shrtckg_grde_code_final AS "Final_Grade"

FROM
    shrtckg s1
    JOIN shrtckn ON shrtckn_seq_no = shrtckg_tckn_seq_no AND shrtckn_pidm = s1.shrtckg_pidm AND shrtckn_term_code = s1.shrtckg_term_code
    JOIN spriden ON shrtckn_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sfrensp a1 ON shrtckn_pidm = a1.sfrensp_pidm AND shrtckn_stsp_key_sequence = a1.sfrensp_key_seqno
    
WHERE 
    1=1

    -- Pick the latest grade for each module in Academic History
    AND s1.shrtckg_seq_no = (SELECT MAX(s2.shrtckg_seq_no) FROM shrtckg s2 WHERE s2.shrtckg_pidm = s1.shrtckg_pidm AND s2.shrtckg_term_code = s1.shrtckg_term_code AND s2.shrtckg_tckn_seq_no = s1.shrtckg_tckn_seq_no)

    -- Limit to grades of IC
    AND s1.shrtckg_grde_code_final = 'IC'
    
    -- Limit to students in specified popsel
    AND spriden_pidm in (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = :popsel_name AND glbextr_user_id = :popsel_user)
    
    -- Identify the maximum enrolment status record that isn't EL
    AND a1.sfrensp_term_code = (
        SELECT MAX(a2.sfrensp_term_code)
        FROM sfrensp a2
        WHERE a1.sfrensp_pidm = a2.sfrensp_pidm AND a1.sfrensp_key_seqno = a2.sfrensp_key_seqno AND a2.sfrensp_ests_code != 'EL'
    )
    
    -- Limit to students who have not withdrawn
    AND a1.sfrensp_ests_code NOT IN ('WD','XF')

ORDER BY
    shrtckn_term_code, 
    shrtckn_subj_code, 
    shrtckn_crse_numb,
    spriden_first_name ||' ' || spriden_last_name
;


SELECT * FROM sfrensp;