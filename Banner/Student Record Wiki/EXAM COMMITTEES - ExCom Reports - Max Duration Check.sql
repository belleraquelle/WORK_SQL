/*
 * This will list out all students who are approaching / breached their maximum duration.
 * It will identify Postgraduate students where more than 48 months have elapsed since their start date.
 * It will identify Undergraduate students where more than 84 months have elapsed since their start date.
 * 
 */


SELECT DISTINCT
	a1.spriden_id AS "Student_Number",
	a1.spriden_last_name || ', ' || spriden_first_name AS "Student_Name", 
	b1.sorlcur_program AS "Programme", 
	b1.sorlcur_coll_code AS "Faculty",
	b1.sorlcur_camp_code AS "Campus",
	CASE
		WHEN e1.UMP_1 = 'Y' THEN 'Y'
		ELSE 'N'
	END AS "UMP",
	c1.sfbetrm_term_code AS "Term_Code",
	c1.sfbetrm_ests_code AS "Enrolment_Code",
	d1.sfrensp_ests_code AS "SP_Enrolment_Code",
	b1.sorlcur_start_date AS "Start_Date",
	MONTHS_BETWEEN(sysdate, b1.sorlcur_start_date)
	
FROM
	spriden a1 -- Person Record
	JOIN sorlcur b1 ON a1.spriden_pidm = b1.sorlcur_pidm -- Curriculum Record
	JOIN sfbetrm c1 ON a1.spriden_pidm = c1.sfbetrm_pidm -- Termly Enrolment Record
	JOIN sfrensp d1 ON b1.sorlcur_pidm = d1.sfrensp_pidm AND b1.sorlcur_key_seqno = d1.sfrensp_key_seqno AND c1.sfbetrm_term_code = d1.sfrensp_term_code -- Termly Study Path Enrolment Record
	JOIN sobcurr_add e1 ON b1.sorlcur_program = e1.sobcurr_program -- Course record (SOACURR)
	JOIN sgbstdn f1 ON a1.spriden_pidm = f1.sgbstdn_pidm -- Learner Record
	JOIN sgrstsp g1 ON b1.sorlcur_pidm = g1.sgrstsp_pidm AND b1.sorlcur_key_seqno = sgrstsp_key_seqno -- Study Path Record
	
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
	
	-- Pick a term
	AND c1.sfbetrm_term_code = :term_code
	
	-- Limit to PG students who have been on study path greater than 48 months and UG students who have been on study path greater than 84 months
	AND CASE
		WHEN b1.sorlcur_levl_code = 'PG' AND MONTHS_BETWEEN(sysdate, b1.sorlcur_start_date) > 48 THEN 1
		WHEN b1.sorlcur_levl_code = 'UG' AND MONTHS_BETWEEN(sysdate, b1.sorlcur_start_date) > 84 THEN 1
		ELSE 0
	END = 1
	
ORDER BY
	"UMP",
	"Faculty",
	"Campus",
	"Programme",
	"Student_Name"
;