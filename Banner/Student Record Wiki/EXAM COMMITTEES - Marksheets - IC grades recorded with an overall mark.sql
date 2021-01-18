/*
 * IC grades should only really be inserted where it is not possible to calculate an overall score for the student i.e. we are missing one or more component marks.
 * This query identifies any students where they have an overall mark recorded in SHRCMRK and their current grade in SHRTCKG is an IC. 
 * To correct where the grade hasn't been calculated automatically, I've typically moderated one of the component marks, saved, and then moderated it back to the original mark, and saved again. 
 * This will trigger Banner to recalculate the final grade and replace the IC correctly. 
 */



SELECT
    spriden_id AS "Student_Number",
    spriden_first_name ||' ' || spriden_last_name AS "Student_Name",
    shrtckn_term_code AS "Term_Code",
    shrtckn_ptrm_code AS "Part_of_Term",
    shrtckn_crn AS "CRN",
    shrtckn_subj_code AS "Subject",
    shrtckn_crse_numb AS "Course_Number",
    shrtckn_crse_title AS "Module_Title",
    shrtckg_grde_code_final AS "Final_Grade",
    shrcmrk_percentage AS "Overall_Mark"

FROM
    shrtckg s1
    JOIN shrtckn ON shrtckn_seq_no = shrtckg_tckn_seq_no AND shrtckn_pidm = s1.shrtckg_pidm AND shrtckn_term_code = s1.shrtckg_term_code
    JOIN spriden ON shrtckn_pidm = spriden_pidm AND spriden_change_ind IS NULL
    LEFT JOIN shrcmrk ON shrtckn_pidm = shrcmrk_pidm AND shrtckn_term_code = shrcmrk_term_code AND shrtckn_crn = shrcmrk_crn
    
WHERE 
    1=1

    -- Pick the latest grade for each module in Academic History
    AND s1.shrtckg_seq_no = (SELECT MAX(s2.shrtckg_seq_no) FROM shrtckg s2 WHERE s2.shrtckg_pidm = s1.shrtckg_pidm AND s2.shrtckg_term_code = s1.shrtckg_term_code AND s2.shrtckg_tckn_seq_no = s1.shrtckg_tckn_seq_no)

    -- Limit to grades of IC
    AND s1.shrtckg_grde_code_final = 'IC'
    
    -- Limit to records that have an overall mark
    AND shrcmrk_percentage IS NOT NULL
    
    -- Limit to students in specified popsel
    --AND spriden_pidm in (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = :popsel_name AND glbextr_user_id = :popsel_user)

ORDER BY
    shrtckn_term_code, 
    shrtckn_subj_code, 
    shrtckn_crse_numb,
    spriden_first_name ||' ' || spriden_last_name
;