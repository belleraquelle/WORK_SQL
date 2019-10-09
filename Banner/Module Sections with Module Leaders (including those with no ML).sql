SELECT 
    ssbsect_term_code,
    ssbsect_crn,
    ssbsect_subj_code,
    ssbsect_crse_numb,
    sirasgn_pidm,
    spriden_id,
    spriden_last_name,
    spriden_first_name,
    sirasgn_primary_ind
FROM 
    sirasgn
    RIGHT JOIN ssbsect ON sirasgn_term_code = ssbsect_term_code AND sirasgn_crn = ssbsect_crn
    LEFT JOIN spriden ON sirasgn_pidm = spriden_pidm
WHERE 
    1=1
    --AND sirasgn_pidm IS NULL 
    AND ssbsect_term_code = '201909'
    AND spriden_change_ind IS NULL
ORDER BY 
    SSBSECT_SUBJ_CODE, 
    SSBSECT_CRSE_NUMB
;