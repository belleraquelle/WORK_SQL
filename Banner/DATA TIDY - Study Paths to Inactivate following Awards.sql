SELECT 

    spriden1.spriden_id AS "StudentNumber",
    shrdgmr1.shrdgmr_pidm AS "AwardPidm",
    shrdgmr1.shrdgmr_degs_code AS "AwardStatus",
    shrdgmr1.shrdgmr_grad_date AS "AwardDate",
    shrdgmr1.shrdgmr_stsp_key_sequence AS "AwardStudyPath",
    sorlcur1.sorlcur_end_date AS "OutcomeEndDate",
    sgrstsp1.sgrstsp_term_code_eff AS "StudyPathTermEffective",
    sgrstsp1.sgrstsp_stsp_code AS "StudyPathStatus",
    sgrstsp1.sgrstsp_key_seqno AS "StudyPath",
    CASE
        WHEN sorlcur1.sorlcur_end_date BETWEEN '01-MAY-20' AND '31-AUG-20' THEN '202009'
        WHEN sorlcur1.sorlcur_end_date BETWEEN '01-SEP-19' AND '31-DEC-19' THEN '202001'
        WHEN sorlcur1.sorlcur_end_date BETWEEN '01-JAN-20' AND '31-MAY-20' THEN '202006'
        ELSE '202006'
    END AS "InactivateStudyPathTermEffective" 
    
FROM

    shrdgmr shrdgmr1
    
    JOIN spriden spriden1
        ON shrdgmr1.shrdgmr_pidm = spriden1.spriden_pidm AND spriden1.spriden_change_ind IS NULL
    
    JOIN sorlcur sorlcur1
        ON shrdgmr1.shrdgmr_pidm = sorlcur1.sorlcur_pidm 
        AND shrdgmr1.shrdgmr_stsp_key_sequence = sorlcur1.sorlcur_key_seqno
        AND sorlcur1.sorlcur_lmod_code = 'OUTCOME'
        AND sorlcur1.sorlcur_seqno = (SELECT MAX(sorlcur2.sorlcur_seqno) FROM sorlcur sorlcur2 WHERE sorlcur1.sorlcur_pidm = sorlcur2.sorlcur_pidm AND sorlcur1.sorlcur_key_seqno = sorlcur2.sorlcur_key_seqno AND sorlcur2.sorlcur_lmod_code = 'OUTCOME')
    
    JOIN sgrstsp sgrstsp1 
        ON shrdgmr1.shrdgmr_pidm = sgrstsp1.sgrstsp_pidm 
        AND shrdgmr1.shrdgmr_stsp_key_sequence = sgrstsp1.sgrstsp_key_seqno 
        AND sgrstsp1.sgrstsp_term_code_eff = (SELECT MAX(sgrstsp2.sgrstsp_term_code_eff) FROM sgrstsp sgrstsp2 WHERE sgrstsp1.sgrstsp_pidm = sgrstsp2.sgrstsp_pidm AND sgrstsp1.sgrstsp_key_seqno = sgrstsp2.sgrstsp_key_seqno)

WHERE

    1=1
    AND shrdgmr1.shrdgmr_degs_code = 'AW'
    AND sgrstsp1.sgrstsp_stsp_code = 'AS'
    
    -- Exclude students who have a study path with an end date in the future
    AND sorlcur1.sorlcur_pidm NOT IN ( 
    
    	SELECT x1.sorlcur_pidm
    	FROM sorlcur x1
    	WHERE
    		1=1
    		AND x1.sorlcur_lmod_code = 'LEARNER'
    		AND x1.sorlcur_cact_code = 'ACTIVE'
    		AND x1.sorlcur_current_cde = 'Y'
    		AND x1.sorlcur_term_code = (
    			SELECT MAX(x2.sorlcur_term_code)
    			FROM sorlcur x2
    			WHERE 
    				x1.sorlcur_pidm = x2.sorlcur_pidm
    				AND x1.sorlcur_key_seqno = x2.sorlcur_key_seqno
    				AND x2.sorlcur_lmod_code = 'LEARNER'
    				AND x2.sorlcur_cact_code = 'ACTIVE'
    				AND x2.sorlcur_current_cde = 'Y'
    		)
    		AND x1.sorlcur_end_date > '01-SEP-20'
    		
    )
    
    
;


SELECT DISTINCT
	spriden_id, spriden_pidm
FROM 
	spriden
	JOIN sgbstdn a1 ON spriden_pidm = a1.sgbstdn_pidm
WHERE

	1=1
	
	-- No active study paths
	AND spriden_pidm NOT IN ( 
		SELECT sgrstsp_pidm
		FROM sgrstsp sgrstsp1
		WHERE 
			1=1
			AND sgrstsp1.sgrstsp_term_code_eff = (
				SELECT MAX(sgrstsp2.sgrstsp_term_code_eff) 
				FROM sgrstsp sgrstsp2 
				WHERE 
					sgrstsp1.sgrstsp_pidm = sgrstsp2.sgrstsp_pidm 
					AND sgrstsp1.sgrstsp_key_seqno = sgrstsp2.sgrstsp_key_seqno
				)
			AND sgrstsp_stsp_code = 'AS'
		) 
	
	-- Max learner record is Active
	AND  a1.sgbstdn_term_code_eff = ( 
		SELECT MAX(a2.sgbstdn_term_code_eff)
		FROM sgbstdn a2
		WHERE a1.sgbstdn_pidm = a2.sgbstdn_pidm
	)
	AND sgbstdn_stst_code = 'AS'
;


SELECT spriden_id FROM spriden WHERE spriden_pidm = '1331689'
	