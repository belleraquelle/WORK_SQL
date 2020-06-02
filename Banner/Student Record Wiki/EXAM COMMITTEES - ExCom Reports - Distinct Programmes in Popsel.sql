/*
 * This report gives a list of all of the programmes broken out by faculty/campus amongst the students in the specified POPSEL.
 * 
 * It can be used to generate a checking list of programmes to log progress through mark-up and exam committees.
 * 
 */


SELECT DISTINCT
	b1.sorlcur_coll_code AS "Faculty",
	b1.sorlcur_camp_code AS "Campus",
	b1.sorlcur_program AS "Programme_Code",
	j1.smrprle_program_desc AS "Programme_Description",
	COUNT(DISTINCT sorlcur_pidm) AS "Student_Count"
	
FROM
	spriden a1 -- Person Record
	JOIN sorlcur b1 ON a1.spriden_pidm = b1.sorlcur_pidm -- Curriculum Record
	JOIN sobcurr_add e1 ON b1.sorlcur_program = e1.sobcurr_program -- Course record (SOACURR)
	JOIN sgbstdn f1 ON a1.spriden_pidm = f1.sgbstdn_pidm -- Learner Record
	JOIN sgrstsp g1 ON b1.sorlcur_pidm = g1.sgrstsp_pidm AND b1.sorlcur_key_seqno = sgrstsp_key_seqno -- Study Path Record
	JOIN smrprle j1 ON b1.sorlcur_program = j1.smrprle_program -- Programme Record for Title
	
WHERE
	1=1
	
	-- Select current SPRIDEN record
	AND a1.spriden_change_ind IS NULL
	
	-- Select Maximum Current SORLCUR record
	AND b1.sorlcur_lmod_code = 'LEARNER'
	AND b1.sorlcur_current_cde = 'Y'
	AND b1.sorlcur_cact_code = 'ACTIVE'
	AND b1.sorlcur_term_code = (
	
		SELECT MAX(b2.sorlcur_term_code)
		FROM sorlcur b2
		WHERE
			1=1
			AND b1.sorlcur_pidm = b2.sorlcur_pidm
			AND b1.sorlcur_key_seqno = b2.sorlcur_key_seqno
			AND b2.sorlcur_lmod_code = 'LEARNER'
			AND b2.sorlcur_current_cde = 'Y'
			AND b2.sorlcur_cact_code = 'ACTIVE'
	
	)
	
	-- Select Maximum Learner Record
	AND f1.sgbstdn_term_code_eff = ( 
	
		SELECT MAX(f2.sgbstdn_term_code_eff)
		FROM sgbstdn f2
		WHERE f1.sgbstdn_pidm = f2.sgbstdn_pidm
	
	)
	
	-- Select Maximum Study Path Record
	AND g1.sgrstsp_term_code_eff = ( 
	
		SELECT MAX(g2.sgrstsp_term_code_eff)
		FROM sgrstsp g2
		WHERE g1.sgrstsp_pidm = g2.sgrstsp_pidm AND g1.sgrstsp_key_seqno = g2.sgrstsp_key_seqno
	
	)
	
	-- Limit to active students
	AND f1.sgbstdn_stst_code = 'AS'
	
	-- Limit to active study paths
	AND g1.sgrstsp_stsp_code = 'AS'


	-- Limit to records in specified popsel
	AND spriden_pidm in (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = :popsel_name AND glbextr_user_id = :popsel_user)

GROUP BY 
	b1.sorlcur_program,
	j1.smrprle_program_desc,
	b1.sorlcur_coll_code,
	b1.sorlcur_camp_code
	
ORDER BY 
	b1.sorlcur_coll_code, 
	b1.sorlcur_program,
	b1.sorlcur_camp_code
	
;