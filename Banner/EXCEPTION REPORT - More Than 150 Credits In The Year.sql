SELECT 
    spriden_id,
    s1.sfrstcr_pidm,
    sorlcur_term_code, 
    sorlcur_term_code_end,
    sorlcur_program,
    sorlcur_styp_code,
    SUM(s1.sfrstcr_credit_hr) AS "Credit"
    
FROM
    sfrstcr s1
    JOIN ssbsect ON s1.sfrstcr_crn = ssbsect_crn AND s1.sfrstcr_term_code = ssbsect_term_code
    JOIN sorlcur a1 ON s1.sfrstcr_pidm = a1.sorlcur_pidm AND a1.sorlcur_lmod_code = 'LEARNER'
    JOIN spriden ON s1.sfrstcr_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sfrensp ON a1.sorlcur_pidm = sfrensp_pidm AND a1.sorlcur_key_seqno = sfrensp_key_seqno
    JOIN sgrstsp t1 ON a1.sorlcur_pidm = t1.sgrstsp_pidm AND a1.sorlcur_key_seqno = t1.sgrstsp_key_seqno
  	JOIN sgbstdn t4 ON a1.sorlcur_pidm = t4.sgbstdn_pidm
	
WHERE
    1=1
      -- Pick out correct sorlcur records for current AY
    AND a1.sorlcur_term_code = (
        SELECT MAX(a2.sorlcur_term_code) 
        FROM sorlcur a2 
        WHERE a1.sorlcur_pidm = a2.sorlcur_pidm AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno AND a1.sorlcur_lmod_code = 'LEARNER' AND a2.sorlcur_cact_code = 'ACTIVE' AND a2.sorlcur_current_cde = 'Y'
        )    
    --AND (('202101' BETWEEN sorlcur_term_code AND sorlcur_term_code_end) OR sorlcur_term_code_end IS NULL)
    AND sorlcur_end_date >= '01-MAY-21'
    AND sorlcur_cact_code = 'ACTIVE'
    AND sorlcur_current_cde = 'Y'
    
    -- Current student status is Active
    AND t4.sgbstdn_term_code_eff = (
        SELECT MAX(e2.sgbstdn_term_code_eff)
        FROM sgbstdn e2
        WHERE t4.sgbstdn_pidm = e2.sgbstdn_pidm
    )
    AND sgbstdn_stst_code = 'AS'
    
    -- Current study path status is Active
    AND t1.sgrstsp_term_code_eff = (
        SELECT MAX(a2.sgrstsp_term_code_eff)
        FROM sgrstsp a2
        WHERE t1.sgrstsp_pidm = a2.sgrstsp_pidm AND t1.sgrstsp_key_seqno = a2.sgrstsp_key_seqno
    )
    AND t1.sgrstsp_stsp_code = 'AS'
    
    -- Student is enrolled for specified term
    AND sfrensp_term_code = '202009'
    AND sfrensp_ests_code = 'EN'
    
    
    -- Only include registered modules in the count
    AND s1.sfrstcr_rsts_code IN ('RE','RW', 'RC')
    
    -- Limit to modules that end in the current AY
    AND ssbsect_ptrm_end_date BETWEEN '01-SEP-20' AND '31-AUG-21'
    
    -- Limit to foundation / undergraduate students
    AND sorlcur_levl_code IN ('FD','UG')
    
    -- Exclude students on SW this AY
    AND s1.sfrstcr_pidm NOT IN (
        SELECT sgrsatt_pidm
        FROM sgrsatt
        WHERE sgrsatt_term_code_eff = '202009' AND sgrsatt_atts_code = 'SW'
    )
    
    -- Exclude specific wonky courses
    AND sorlcur_program NOT LIKE '%DA'
    AND sorlcur_program NOT LIKE 'UGASSO%'
    AND sorlcur_program != 'UGAQ/D'
    AND sorlcur_program NOT LIKE 'FDA%'
    
    -- Only include students enrolled in both S1 and S2
    AND s1.sfrstcr_pidm IN (SELECT sfrensp_pidm FROM sfrensp WHERE sfrensp_term_code = '202009' AND sfrensp_ests_code = 'EN')
    AND s1.sfrstcr_pidm IN (SELECT sfrensp_pidm FROM sfrensp WHERE sfrensp_term_code = '202101' AND sfrensp_ests_code = 'EN')
    
    -- Exclude students on exchange
    AND s1.sfrstcr_pidm NOT IN (
        SELECT s2.sfrstcr_pidm 
        FROM sfrstcr s2 JOIN ssbsect z1 ON s2.sfrstcr_crn = z1.ssbsect_crn AND s2.sfrstcr_term_code = z1.ssbsect_term_code 
        WHERE s2.sfrstcr_rsts_code IN ('RE','RW') AND z1.ssbsect_subj_code = 'EXCH' AND ssbsect_term_code IN ('202009','202101')
    )
    
    
    
GROUP BY
    spriden_id,
    s1.sfrstcr_pidm,
    sorlcur_term_code, 
    sorlcur_term_code_end,
    sorlcur_styp_code,
    sorlcur_program

HAVING
    SUM(s1.sfrstcr_credit_hr) > 150
    
ORDER BY 
    sorlcur_program,
    spriden_id
;