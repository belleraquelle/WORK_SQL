SELECT 
    ssbsect_term_code,
    ssbsect_ptrm_code,
    ssbsect_crn,
    ssbsect_subj_code,
    ssbsect_crse_numb,
    c1.scbcrse_title,
    sirasgn_pidm,
    spriden_id,
    spriden_last_name,
    spriden_first_name,
    sirasgn_primary_ind
FROM 
    sirasgn
    RIGHT JOIN ssbsect ON sirasgn_term_code = ssbsect_term_code AND sirasgn_crn = ssbsect_crn
    RIGHT JOIN scbcrse c1 ON ssbsect_subj_code = c1.scbcrse_subj_code AND ssbsect_crse_numb = c1.scbcrse_crse_numb AND c1.scbcrse_eff_term = (SELECT MAX(c2.scbcrse_eff_term) FROM scbcrse c2 WHERE c2.scbcrse_subj_code = c1.scbcrse_subj_code AND c2.scbcrse_crse_numb = c1.scbcrse_crse_numb) -- Issue here with courses that have changed name over time. Would need to return the title that the section's term code falls within
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