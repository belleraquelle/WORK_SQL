SELECT DISTINCT
    spriden_id, 
    shrtckn_term_code,
    shrtckn_subj_code,
    shrtckn_crse_numb,
    shrtckn_crn,
    shrtckg_seq_no,
    shrtckg_grde_code_final, 
    shrcmrk_percentage
FROM
    shrtckn
    JOIN shrtckg ON shrtckn_pidm = shrtckg_pidm AND shrtckn_term_code = shrtckg_term_code AND shrtckn_seq_no = shrtckg_tckn_seq_no
    JOIN shrcmrk ON shrtckn_pidm = shrcmrk_pidm AND shrtckn_term_code = shrcmrk_term_code AND shrtckn_crn = shrcmrk_crn
    JOIN spriden ON shrtckn_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
    1=1
    AND shrtckg_grde_code_final = 'S'
    AND shrcmrk_percentage IS NOT NULL
ORDER BY
    shrtckn_subj_code, shrtckn_crse_numb
;