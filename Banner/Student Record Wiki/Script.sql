SELECT
	a1.spriden_id AS "Student_ID",
	g1.sgrstsp_key_seqno AS "Study_Path",
	b1.sorlcur_program AS "Programme_of_Study",
	--h1.shrtckn_term_code AS "Term_Code",
	--h1.shrtckn_subj_code AS "Subject_Code",
	--h1.shrtckn_crse_numb AS "Course_Number",
	--i1.shrtckg_grde_code_final AS "Final_Grade",
	--i1.shrtckg_credit_hours AS "Credit_Hours",
	--j1.scrattr_attr_code AS "Level",
	--l1.shrgrde_passed_ind AS "Pass_Indicator",
	SUM(i1.shrtckg_credit_hours) AS "Total_Passed_Credit"
	

FROM
	spriden a1 -- Person Record
	JOIN sorlcur b1 ON a1.spriden_pidm = b1.sorlcur_pidm -- Curriculum Record
	JOIN sgbstdn f1 ON a1.spriden_pidm = f1.sgbstdn_pidm -- Learner Record
	JOIN sgrstsp g1 ON b1.sorlcur_pidm = g1.sgrstsp_pidm AND b1.sorlcur_key_seqno = sgrstsp_key_seqno -- Study Path Record
	JOIN shrtckn h1 ON a1.spriden_pidm = h1.shrtckn_pidm AND g1.sgrstsp_key_seqno = shrtckn_stsp_key_sequence -- Academic History Records
	JOIN shrtckg i1 ON h1.shrtckn_pidm = i1.shrtckg_pidm AND h1.shrtckn_term_code = i1.shrtckg_term_code AND h1.shrtckn_seq_no = i1.shrtckg_tckn_seq_no -- Grade Record
	JOIN scrattr j1 ON h1.shrtckn_subj_code = j1.scrattr_subj_code AND h1.shrtckn_crse_numb = j1.scrattr_crse_numb -- Module Attributes
	JOIN shrtckl k1 ON h1.shrtckn_pidm = k1.shrtckl_pidm AND h1.shrtckn_term_code = k1.shrtckl_term_code AND h1.shrtckn_seq_no = k1.shrtckl_tckn_seq_no -- Level Record for Modules in Academic History
	JOIN shrgrde l1 ON i1.shrtckg_grde_code_final = l1.shrgrde_code AND k1.shrtckl_levl_code = l1.shrgrde_levl_code -- Grade Details
	
WHERE
	1=1
	
	-- Limit to students in specified POPSEL
	AND a1.spriden_pidm IN (
		SELECT glbextr_key 
		FROM glbextr 
		WHERE glbextr_selection = :popsel_name AND glbextr_user_id = :popsel_user
		)
	
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
	
	-- Select Maximum Grade Record
	AND i1.shrtckg_seq_no = (
	
		SELECT MAX(i2.shrtckg_seq_no)
		FROM shrtckg i2
		WHERE i1.shrtckg_pidm = i2.shrtckg_pidm AND i1.shrtckg_term_code = i2.shrtckg_term_code AND i1.shrtckg_tckn_seq_no = i2.shrtckg_tckn_seq_no
	
	)
	
	-- Limit to active students
	AND f1.sgbstdn_stst_code = 'AS'
	
	-- Limit to active study paths
	AND g1.sgrstsp_stsp_code = 'AS'
	
	-- Limit to modules from the following levels
	AND j1.scrattr_attr_code IN ('L3','L4')
	
	-- Limit to modules that the student has passed
	AND l1.shrgrde_passed_ind = 'Y'
	
	-- Only include FNDIPs
	AND b1.sorlcur_program LIKE 'F%'
	
GROUP BY 
	a1.spriden_id,
	g1.sgrstsp_key_seqno,
	b1.sorlcur_program
	--h1.shrtckn_term_code,
	--h1.shrtckn_subj_code,
	--h1.shrtckn_crse_numb,
	--i1.shrtckg_grde_code_final,
	--i1.shrtckg_credit_hours,
	--j1.scrattr_attr_code
	--l1.shrgrde_passed_ind
	
HAVING 
	SUM(i1.shrtckg_credit_hours) >= 120
	
ORDER BY 
	a1.spriden_id
	
;


SELECT * FROM shrtckn;

SELECT * FROM SHRTCKL;

SELECT * FROM shrtckg;

SELECT * FROM shrgrde;

