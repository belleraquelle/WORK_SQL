/*
 * This report can be used to identify specific decision codes against a term and within specified population
 * selections. 
 * 
 * It can be used to, for example, find unresolved D3s at the July committees.
 */

SELECT 
	spriden_id AS "Student_Number",
	spriden_last_name AS "Last_Name",
	spriden_first_name AS "First_Name",
	b1.sorlcur_program AS "Course",
	glbextr_selection AS "Population",
	shrapsp.*
	
FROM 
	shrapsp
	JOIN glbextr ON shrapsp_pidm = glbextr_key
	JOIN spriden ON shrapsp_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur b1 ON shrapsp_pidm = b1.sorlcur_pidm AND shrapsp_stsp_key_sequence = b1.sorlcur_key_seqno
WHERE
	1=1
	AND shrapsp_term_code = :term_code
	AND shrapsp_astd_code_end_of_term = :decision_code
	AND glbextr_selection IN ('202007-UG-STAGE1','202007-UG-STAGEII','202007_GOLD')
	
	-- Latest Learner SORLCUR
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
;

SELECT * FROM GLBEXTR;