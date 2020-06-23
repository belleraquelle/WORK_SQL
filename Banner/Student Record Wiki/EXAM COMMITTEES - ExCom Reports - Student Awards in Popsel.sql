/*
 * This report gives a list of all of the status PN and status AW awards against students in the specified popsel.
 * 
 * It can be used to generate a list of awards following the committee for checking and verification purposes.
 * 
 */


SELECT DISTINCT
	a1.spriden_id AS "Student_ID",
	a1.spriden_last_name || ', ' || a1.spriden_first_name AS "Student_Name",
	b1.sorlcur_coll_code AS "Faculty",
	b1.sorlcur_camp_code AS "Campus",
	--b1.sorlcur_program AS "Programme_Code",
	--j1.smrprle_program_desc AS "Programme_Description",
	l1.sorlcur_program AS "Award_Programme_Code",
	n1.smrprle_program_desc AS "Award_Programme_Description",
	k1.shrdgmr_degc_code AS "Award_Code",
	k1.shrdgmr_degs_code AS "Award_Status",
	o1.shrdgcm_comment AS "Average",
	m1.shrdgih_honr_code AS "Classification",
	k1.shrdgmr_grad_date AS "Award_Date"
	
FROM
	spriden a1 -- Person Record
	JOIN sorlcur b1 ON a1.spriden_pidm = b1.sorlcur_pidm -- Curriculum Record
	JOIN sobcurr_add e1 ON b1.sorlcur_program = e1.sobcurr_program -- Course record (SOACURR)
	JOIN sgbstdn f1 ON a1.spriden_pidm = f1.sgbstdn_pidm -- Learner Record
	JOIN sgrstsp g1 ON b1.sorlcur_pidm = g1.sgrstsp_pidm AND b1.sorlcur_key_seqno = sgrstsp_key_seqno -- Study Path Record
	JOIN smrprle j1 ON b1.sorlcur_program = j1.smrprle_program -- Programme Record for Title
	LEFT JOIN shrdgmr k1 ON b1.sorlcur_pidm = k1.shrdgmr_pidm AND b1.sorlcur_key_seqno = k1.shrdgmr_stsp_key_sequence -- Award Record
	LEFT JOIN sorlcur l1 ON k1.shrdgmr_pidm = l1.sorlcur_pidm AND k1.shrdgmr_seq_no = l1.sorlcur_key_seqno AND l1.sorlcur_lmod_code = 'OUTCOME' AND l1.sorlcur_current_cde = 'Y' -- Award Curriculum Record
	LEFT JOIN shrdgih m1 ON k1.shrdgmr_pidm = m1.shrdgih_pidm AND k1.shrdgmr_seq_no = m1.shrdgih_dgmr_seq_no -- Classification Record
	LEFT JOIN smrprle n1 ON l1.sorlcur_program = n1.smrprle_program -- Programme Record for Title
	LEFT JOIN shrdgcm o1 ON k1.shrdgmr_pidm = o1.shrdgcm_pidm AND k1.shrdgmr_seq_no = o1.shrdgcm_dgmr_seq_no
	
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
	AND a1.spriden_pidm in (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = :popsel_name AND glbextr_user_id = :popsel_user)
	
	-- Limit to PN or AW awards
	AND k1.shrdgmr_degs_code IN ('AW','PN')
	
	-- Limit to 'future' awards
	AND shrdgmr_grad_date > sysdate

	
ORDER BY 
	b1.sorlcur_coll_code, 
	l1.sorlcur_program,
	b1.sorlcur_camp_code
	
;


SELECT * FROM shrdgmr;

SELECT * FROM shrdgcm;