SELECT DISTINCT
	--COUNT(student.spriden_id)
    s1.sorlcur_term_code_admit AS "Admit Term", 
    s1.sorlcur_program AS "Programme", 
    student.SPRIDEN_ID AS Student_ID, 
    student.SPRIDEN_LAST_NAME||', '|| student.SPRIDEN_FIRST_NAME AS Student, 
    advisor.SPRIDEN_ID AS Advisor_ID, 
    advisor.SPRIDEN_LAST_NAME ||', '|| advisor.SPRIDEN_FIRST_NAME AS Advisor, 
    z1.SGRADVR_TERM_CODE_EFF AS Term, 
    z1.SGRADVR_ADVR_CODE, 
    z1.SGRADVR_PRIM_IND,
    sorlcur_end_date
FROM 
    sgradvr z1
    JOIN sorlcur s1 ON z1.sgradvr_pidm = s1.sorlcur_pidm 
    JOIN spriden student ON z1.sgradvr_pidm = student.spriden_pidm AND student.spriden_change_ind IS NULL
    JOIN spriden advisor ON z1.sgradvr_advr_pidm = advisor.spriden_pidm --AND advisor.spriden_change_ind IS NULL
    JOIN sgrstsp p1 ON z1.sgradvr_pidm = p1.sgrstsp_pidm AND sorlcur_key_seqno = p1.sgrstsp_key_seqno
    JOIN sgbstdn t1 ON z1.sgradvr_pidm = t1.sgbstdn_pidm
    
WHERE 
    1=1
    
    -- Max learner end date is in the future
    AND s1.sorlcur_lmod_code = 'LEARNER'
    AND s1.sorlcur_cact_code = 'ACTIVE'
    AND s1.sorlcur_current_cde = 'Y'
    AND s1.sorlcur_term_code = (
    
    	SELECT MAX(s2.sorlcur_term_code)
    	FROM sorlcur s2
    	WHERE
    		s1.sorlcur_pidm = s2.sorlcur_pidm
    		AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno
    		AND s2.sorlcur_lmod_code = 'LEARNER'
    		AND s2.sorlcur_cact_code = 'ACTIVE'
    		AND s2.sorlcur_current_cde = 'Y'
    	
    )
    AND s1.sorlcur_end_date > sysdate
    
    -- Max study path record is active
    AND p1.sgrstsp_term_code_eff = (
    
    	SELECT MAX(p2.sgrstsp_term_code_eff)
    	FROM sgrstsp p2
    	WHERE
    		p1.sgrstsp_pidm = p2.sgrstsp_pidm
    		AND p1.sgrstsp_key_seqno = p2.sgrstsp_key_seqno
    	
    )
    AND p1.sgrstsp_stsp_code = 'AS'
    
    -- Max learner record is active
    AND t1.sgbstdn_term_code_eff = ( 
    
    	SELECT MAX(t2.sgbstdn_term_code_eff)
    	FROM sgbstdn t2
    	WHERE t1.sgbstdn_pidm = t2.sgbstdn_pidm
    
    )
    
    AND t1.sgbstdn_stst_code = 'AS'
    
    -- Limit to current advisor record
    AND z1.sgradvr_term_code_eff = (SELECT MAX (z2.sgradvr_term_code_eff) FROM sgradvr z2 WHERE z1.sgradvr_pidm = z2.sgradvr_pidm)
    

    --AND advisor.spriden_id LIKE 'P%'
    AND sgradvr_advr_code = 'T001'
    AND advisor.spriden_id = '19004787'
    --AND student.spriden_id = '19054098'
    --AND s1.sorlcur_program = 'BSCH-NN'
    --AND s1.sorlcur_program != 'FNDIP-IFB'
    
    ORDER BY 
    	sorlcur_end_date,
        student.spriden_id, 
        SGRADVR_ADVR_CODE
;
p0068127
