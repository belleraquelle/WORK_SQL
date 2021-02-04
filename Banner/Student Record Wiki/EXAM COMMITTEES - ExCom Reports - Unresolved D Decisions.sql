/*
 * This query identifies students whose latest decision is a Deferred decision
 * which was recorded in a term other than the one currently going to committee.
 * 
 * These need to be reviewed to see if an updated decision should be recorded. 
 * Especially important at July resit committees.
 */

SELECT 
	spriden_id AS "Student_Number",
	spriden_last_name AS "Last_Name",
	spriden_first_name AS "First_Name",
	b1.sorlcur_program AS "Course",
	glbextr_selection AS "Population",
	s1.shrapsp_term_code AS "Decision_Term",
	s1.shrapsp_astd_code_end_of_term AS "Decision_Code"
	
FROM 
	shrapsp s1
	JOIN glbextr ON shrapsp_pidm = glbextr_key
	JOIN spriden ON shrapsp_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur b1 ON shrapsp_pidm = b1.sorlcur_pidm AND shrapsp_stsp_key_sequence = b1.sorlcur_key_seqno
WHERE
	1=1
	AND s1.shrapsp_term_code = (
		SELECT MAX(s2.shrapsp_term_code)
		FROM shrapsp s2
		WHERE s1.shrapsp_pidm = s2.shrapsp_pidm AND s1.shrapsp_stsp_key_sequence = s2.shrapsp_stsp_key_sequence
	)
	AND glbextr_selection IN ('202101_PINK', '202101_GREY', '202101_GOLD')
	AND shrapsp_term_code != (SELECT gtvsdax_external_code FROM gtvsdax WHERE gtvsdax_internal_code_group = 'OBU' AND gtvsdax_internal_code = 'EXAM_TERM')
	AND shrapsp_astd_code_end_of_term LIKE 'D%'
	
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
ORDER BY 
	"Course",
	"Decision_Code",
	"Last_Name"
;