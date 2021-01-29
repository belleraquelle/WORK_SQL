SELECT DISTINCT
    spriden_id, 
    shrtckn_term_code,
    shrtckn_subj_code,
    shrtckn_crse_numb,
    shrtckn_crn,
    t1.shrtckg_seq_no,
    t1.shrtckg_grde_code_final, 
    shrcmrk_percentage
FROM
    shrtckn
    JOIN shrtckg t1 ON shrtckn_pidm = t1.shrtckg_pidm AND shrtckn_term_code = t1.shrtckg_term_code AND shrtckn_seq_no = t1.shrtckg_tckn_seq_no
    JOIN shrcmrk ON shrtckn_pidm = shrcmrk_pidm AND shrtckn_term_code = shrcmrk_term_code AND shrtckn_crn = shrcmrk_crn
    JOIN spriden ON shrtckn_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
    1=1
    AND t1.shrtckg_seq_no = (SELECT MAX(t2.shrtckg_seq_no) FROM shrtckg t2 WHERE t2.shrtckg_pidm = t1.shrtckg_pidm AND t2.shrtckg_term_code = t1.shrtckg_term_code AND t2.shrtckg_tckn_seq_no = t1.shrtckg_tckn_seq_no)
    AND shrtckg_grde_code_final = 'S'
    AND shrcmrk_percentage IS NOT NULL
ORDER BY
    shrtckn_subj_code, shrtckn_crse_numb
;