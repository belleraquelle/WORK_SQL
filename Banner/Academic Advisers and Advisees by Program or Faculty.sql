/*

This query returns all students on specified program(s) who have an expected completion date in the future,
and lists their current adviser.

*/


SELECT
    s1.spriden_id AS "Student_Number",
    s1.spriden_last_name || ', ' || s1.spriden_first_name AS "Student_Name",
    sorlcur_term_code_admit AS "Admit_Term",
    sorlcur_program AS "Programme",
    sorlcur_end_date AS "Expected_Completion_Date",
    sorlcur_camp_code AS "Campus_Code",
    t1.sgradvr_advr_code AS "Advisor_Code",
    s2.spriden_last_name || ', ' || s2.spriden_first_name AS "Adviser_Name"

FROM
    sorlcur a1
    JOIN spriden s1 ON a1.sorlcur_pidm = s1.spriden_pidm AND s1.spriden_change_ind IS NULL
    LEFT JOIN sgradvr t1 ON a1.sorlcur_pidm = t1.sgradvr_pidm
    LEFT JOIN spriden s2 ON sgradvr_advr_pidm = s2.spriden_pidm AND s2.spriden_change_ind IS NULL
    JOIN sgrstsp p1 ON sgradvr_pidm = p1.sgrstsp_pidm AND sorlcur_key_seqno = p1.sgrstsp_key_seqno
    JOIN sgbstdn t1 ON sgradvr_pidm = t1.sgbstdn_pidm

WHERE
    1=1
    
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
    
    -- Curriculum criteria
    AND a1.sorlcur_lmod_code = 'LEARNER'
    AND a1.sorlcur_cact_code = 'ACTIVE'
    AND a1.sorlcur_current_cde = 'Y'
    AND a1.sorlcur_term_code = ( 
    
    	SELECT MAX(a2.sorlcur_term_code)
    	FROM sorlcur a2
    	WHERE 
    		a1.sorlcur_pidm = a2.sorlcur_pidm
    		AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno
    		AND a2.sorlcur_lmod_code = 'LEARNER'
    		AND a2.sorlcur_cact_code = 'ACTIVE'
    		AND a2.sorlcur_current_cde = 'Y'
    
    )
    
    -- Limit to students with an end date in the future
    AND sorlcur_end_date > sysdate
    
    -- Use these criteria to limit to specific programmes
    --AND sorlcur_program IN ('BSCH-BG','BSCH-EJ','MBIOL-BG') --OR sorlcur_program LIKE '%PX%') -- Enter programme codes here!

    -- Use these criteria to limit to specific college code
    AND sorlcur_coll_code IN ('BU','BT','BL','BH')
    
    -- Max Advisor Record
    AND (t1.sgradvr_term_code_eff = (
            SELECT MAX(t2.sgradvr_term_code_eff)
            FROM sgradvr t2
            WHERE t2.sgradvr_pidm = t1.sgradvr_pidm)
        OR t1.sgradvr_advr_code IS NULL -- Return students who are missing an AA
        )
        
    
ORDER BY
	"Programme",
    s2.spriden_last_name || ', ' || s2.spriden_first_name,
    s1.spriden_last_name || ', ' || s1.spriden_first_name
;