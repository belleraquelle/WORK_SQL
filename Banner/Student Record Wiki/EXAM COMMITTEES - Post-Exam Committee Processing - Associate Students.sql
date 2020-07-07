/*
 * This report gives a breakdown of 'completing' associate students
 * 
 * Can be limited to only show students who have 'passed' modules, and can include CRN and grade info if needed.
 */


SELECT DISTINCT
	a1.spriden_id AS "Student_ID",
	a1.spriden_last_name || ', ' || a1.spriden_first_name AS "Student_Name",
	b1.sorlcur_coll_code AS "Faculty",
	b1.sorlcur_camp_code AS "Campus",
	b1.sorlcur_program AS "Original_Programme",
	b1.sorlcur_end_date AS "Expected_Completion_Date",
	--b1.sorlcur_program AS "Programme_Code",
	j1.smrprle_program_desc AS "Original_Programme_Desc",
	l1.sorlcur_program AS "Award_Programme_Code",
	n1.smrprle_program_desc AS "Award_Programme_Description",
	k1.shrdgmr_degc_code AS "Award_Code",
	k1.shrdgmr_degs_code AS "Award_Status",
	m1.shrdgih_honr_code AS "Classification",
	k1.shrdgmr_grad_date AS "Award_Date",
	k1.shrdgmr_seq_no AS "Degree_Sequence"
--	o1.shrtckn_crn AS "CRN",
--	p1.shrtckg_grde_code_final AS "Grade",
--	shrgrde_passed_ind AS "Passed"
	
FROM
	spriden a1 -- Person Record
	JOIN sorlcur b1 ON a1.spriden_pidm = b1.sorlcur_pidm -- Curriculum Record
	JOIN sobcurr_add e1 ON b1.sorlcur_program = e1.sobcurr_program -- Course record (SOACURR)
	JOIN sgbstdn f1 ON a1.spriden_pidm = f1.sgbstdn_pidm -- Learner Record
	JOIN sgrstsp g1 ON b1.sorlcur_pidm = g1.sgrstsp_pidm AND b1.sorlcur_key_seqno = sgrstsp_key_seqno -- Study Path Record
	JOIN smrprle j1 ON b1.sorlcur_program = j1.smrprle_program -- Programme Record for Title
	LEFT JOIN shrdgmr k1 ON b1.sorlcur_pidm = k1.shrdgmr_pidm AND b1.sorlcur_key_seqno = k1.shrdgmr_stsp_key_sequence -- Award Record
	LEFT JOIN sorlcur l1 ON k1.shrdgmr_pidm = l1.sorlcur_pidm AND k1.shrdgmr_seq_no = l1.sorlcur_key_seqno AND l1.sorlcur_lmod_code = 'OUTCOME' AND l1.sorlcur_term_code_end IS NULL -- Award Curriculum Record
	LEFT JOIN shrdgih m1 ON k1.shrdgmr_pidm = m1.shrdgih_pidm AND k1.shrdgmr_seq_no = m1.shrdgih_dgmr_seq_no -- Classification Record
	LEFT JOIN smrprle n1 ON l1.sorlcur_program = n1.smrprle_program -- Programme Record for Title
	LEFT JOIN shrtckn o1 ON b1.sorlcur_pidm = o1.shrtckn_pidm AND b1.sorlcur_key_seqno = o1.shrtckn_stsp_key_sequence
	LEFT JOIN shrtckg p1 ON o1.shrtckn_pidm = p1.shrtckg_pidm AND o1.shrtckn_term_code = p1.shrtckg_term_code AND o1.shrtckn_seq_no = p1.shrtckg_tckn_seq_no
		AND p1.shrtckg_seq_no = ( 
						
							SELECT MAX(p2.shrtckg_seq_no)
							FROM shrtckg p2
							WHERE p1.shrtckg_pidm = p2.shrtckg_pidm AND p1.shrtckg_tckn_seq_no = p2.shrtckg_tckn_seq_no AND p1.shrtckg_term_code = p2.shrtckg_term_code
						)
	LEFT JOIN shrgrde ON p1.shrtckg_grde_code_final = shrgrde_code AND b1.sorlcur_levl_code = shrgrde_levl_code
	
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
	
	-- Select Maximum Outcome SORLCUR record
	AND l1.sorlcur_lmod_code = 'OUTCOME'
	AND l1.sorlcur_current_cde = 'Y'
	AND l1.sorlcur_cact_code = 'ACTIVE'
	AND l1.sorlcur_term_code = (
	
		SELECT MAX(l2.sorlcur_term_code)
		FROM sorlcur l2
		WHERE
			1=1
			AND l1.sorlcur_pidm = l2.sorlcur_pidm
			AND l1.sorlcur_key_seqno = l2.sorlcur_key_seqno
			AND l2.sorlcur_lmod_code = 'OUTCOME'
			AND l2.sorlcur_current_cde = 'Y'
			AND l2.sorlcur_cact_code = 'ACTIVE'
	
	)
	
	-- Limit to UGASSO / PGASSO students
	AND b1.sorlcur_program IN ('UGASSO', 'PGASSO')
	
	-- Limit to students with expected completion date within this range
	AND b1.sorlcur_end_date BETWEEN :end_date_range_start AND :end_date_range_end
	
	-- Limit to active students
	AND f1.sgbstdn_stst_code = 'AS'
	
	-- Limit to active study paths
	AND g1.sgrstsp_stsp_code = 'AS'
	


	-- Limit to records in specified popsel
	--AND a1.spriden_pidm in (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = :popsel_name AND glbextr_user_id = :popsel_user)
	
	-- Exclude awarded students
	AND (k1.shrdgmr_degs_code != 'AW' OR k1.shrdgmr_degs_code IS NULL)
	
	-- Limit to CHEUs and DHEUs
	--AND l1.sorlcur_program IN ('CHEU', 'DHEU')
	
	-- Limit to students who have passed a module
	--AND shrgrde_passed_ind = 'Y'

	
ORDER BY 
	b1.sorlcur_coll_code, 
	b1.sorlcur_program,
	l1.sorlcur_program
	
;