SELECT 
    spriden_id, 
    shrtckn_pidm,
    shrtckn_term_code,
    shrtckn_seq_no,
    shrtckn_crn,
    shrtckn_subj_code,
    shrtckn_crse_numb,
    shrtckg_grde_code_final,
    shrtckg_seq_no,
    shrmrks_gcom_id,
    shrmrks_user_id, 
    shrmrks_score,
    shrmrks_percentage,
    shrmrks_grde_code,
    shrmrks_completed_date
FROM 
    shrtckn
    JOIN shrmrks ON shrtckn_pidm = shrmrks_pidm AND shrmrks_term_code = shrtckn_term_code AND shrtckn_crn = shrmrks_crn
    JOIN shrtckg a1 ON shrtckn_pidm = a1.shrtckg_pidm AND shrtckn_seq_no = a1.shrtckg_tckn_seq_no AND shrtckn_term_code = a1.shrtckg_term_code
    JOIN spriden ON shrtckn_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
    1=1
    AND shrmrks_score IS NULL
    AND shrmrks_percentage IS NULL
    AND shrmrks_grde_code IS NULL
    AND shrtckn_term_code >= :term_code
    AND a1.shrtckg_seq_no = (
        SELECT MAX(a2.shrtckg_seq_no)
        FROM shrtckg a2
        WHERE a1.shrtckg_pidm = a2.shrtckg_pidm AND a1.shrtckg_term_code = a2.shrtckg_term_code AND a1.shrtckg_tckn_seq_no = a2.shrtckg_tckn_seq_no
    )
    AND a1.shrtckg_grde_code_final NOT IN ('IC', 'DD', 'DR', 'S')
    AND shrtckn_term_code || shrtckn_crn NOT IN (SELECT shrgcom_term_code || shrgcom_crn FROM shrgcom WHERE shrgcom_sub_set = 'OR')
ORDER BY
    shrtckn_subj_code,
    shrtckn_crse_numb;