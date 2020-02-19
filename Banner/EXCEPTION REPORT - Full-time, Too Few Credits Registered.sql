SELECT 
    spriden_id,
    s1.sfrstcr_pidm,
    sorlcur_term_code, 
    sorlcur_term_code_end,
    sorlcur_program,
    sorlcur_styp_code,
    SUM(s1.sfrstcr_credit_hr)
    
FROM
    sfrstcr s1
    JOIN ssbsect ON s1.sfrstcr_crn = ssbsect_crn AND s1.sfrstcr_term_code = ssbsect_term_code
    JOIN sorlcur a1 ON s1.sfrstcr_pidm = a1.sorlcur_pidm AND a1.sorlcur_lmod_code = 'LEARNER'
    JOIN spriden ON s1.sfrstcr_pidm = spriden_pidm AND spriden_change_ind IS NULL
    
WHERE
    1=1
    -- Only include registered modules in the count
    AND s1.sfrstcr_rsts_code IN ('RE','RW')
    
    -- Limit to modules that end in the current AY
    AND ssbsect_ptrm_end_date BETWEEN '01-SEP-19' AND '31-AUG-20'
    
    -- Pick out 'current' sorlcur record
    AND a1.sorlcur_term_code = (
        SELECT MAX(a2.sorlcur_term_code) 
        FROM sorlcur a2 
        WHERE a1.sorlcur_pidm = a2.sorlcur_pidm AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno AND a1.sorlcur_lmod_code = 'LEARNER'
        )    
    AND (('202001' BETWEEN sorlcur_term_code AND sorlcur_term_code_end) OR sorlcur_term_code_end IS NULL)
    AND sorlcur_end_date >= '01-MAY-20'
    AND sorlcur_cact_code = 'ACTIVE'
    AND sorlcur_current_cde = 'Y'
    
    -- Limit to full-time students
    AND sorlcur_styp_code = 'F'
    
    -- Limit to foundation / undergraduate students
    AND sorlcur_levl_code IN ('FD', 'UG')
    
    -- Exclude students on SW this AY
    AND s1.sfrstcr_pidm NOT IN (
        SELECT sgrsatt_pidm
        FROM sgrsatt
        WHERE sgrsatt_term_code_eff = '201909' AND sgrsatt_atts_code = 'SW'
    )
    
    -- Exclude specific wonky courses
    AND sorlcur_program NOT LIKE '%DA'
    AND sorlcur_program NOT LIKE 'UGASSO%'
    AND sorlcur_program != 'UGAQ/D'
    AND sorlcur_program NOT LIKE 'FDA%'
    
    -- Only include students enrolled in both S1 and S2
    AND s1.sfrstcr_pidm IN (SELECT sfrensp_pidm FROM sfrensp WHERE sfrensp_term_code = 201909 AND sfrensp_ests_code = 'EN')
    AND s1.sfrstcr_pidm IN (SELECT sfrensp_pidm FROM sfrensp WHERE sfrensp_term_code = 202001 AND sfrensp_ests_code = 'EN')
    
    -- Exclude students on exchange
    AND s1.sfrstcr_pidm NOT IN (
        SELECT s2.sfrstcr_pidm 
        FROM sfrstcr s2 JOIN ssbsect z1 ON s2.sfrstcr_crn = z1.ssbsect_crn AND s2.sfrstcr_term_code = z1.ssbsect_term_code 
        WHERE s2.sfrstcr_rsts_code IN ('RE','RW') AND z1.ssbsect_subj_code = 'EXCH' AND ssbsect_term_code IN ('201909','202001')
    )
    
GROUP BY
    spriden_id,
    s1.sfrstcr_pidm,
    sorlcur_term_code, 
    sorlcur_term_code_end,
    sorlcur_styp_code,
    sorlcur_program

HAVING
    SUM(s1.sfrstcr_credit_hr) < 90
    
ORDER BY 
    sorlcur_program,
    spriden_id
;