/*
 * This will list out all students who are ACTIVE with an ACTIVE study path who have a current expected completion date
 * before the specified date.
 * 
 * It will include the most recent Exam Committee decision (if any), as well as any award data that there may be in 
 * Banner (e.g. PN status award).
 * 
 * During exam committee, it is worthwhile checking through this list to identify any students who either might need an
 * additional decision (following a failed resit for example), or to pick up any exit awards that we may have missed. 
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
	b1.sorlcur_end_date AS "End_Date",
	h1.shrapsp_term_code AS "ExCom_Decision_Term",
	h1.shrapsp_astd_code_end_of_term AS "ExCom_Decision_Code",
	h1.shrapsp_prev_code AS "ExCom_Additional_Decision_Code",
	i1.shrdgmr_degc_code AS "Award_Type",
	i1.shrdgmr_degs_code AS "Award_Status"
	
FROM
	spriden a1 -- Person Record
	JOIN sorlcur b1 ON a1.spriden_pidm = b1.sorlcur_pidm -- Curriculum Record
	JOIN sfbetrm c1 ON a1.spriden_pidm = c1.sfbetrm_pidm -- Termly Enrolment Record
	JOIN sfrensp d1 ON b1.sorlcur_pidm = d1.sfrensp_pidm AND b1.sorlcur_key_seqno = d1.sfrensp_key_seqno AND c1.sfbetrm_term_code = d1.sfrensp_term_code -- Termly Study Path Enrolment Record
	JOIN sobcurr_add e1 ON b1.sorlcur_program = e1.sobcurr_program -- Course record (SOACURR)
	JOIN sgbstdn f1 ON a1.spriden_pidm = f1.sgbstdn_pidm -- Learner Record
	JOIN sgrstsp g1 ON b1.sorlcur_pidm = g1.sgrstsp_pidm AND b1.sorlcur_key_seqno = sgrstsp_key_seqno -- Study Path Record
	LEFT JOIN shrapsp h1 ON b1.sorlcur_pidm = h1.shrapsp_pidm AND b1.sorlcur_key_seqno = h1.shrapsp_stsp_key_sequence -- Academic Standing Record
	LEFT JOIN shrdgmr i1 ON b1.sorlcur_pidm = i1.shrdgmr_pidm AND b1.sorlcur_key_seqno = i1.shrdgmr_stsp_key_sequence -- Award Record
	
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
	
	-- Select Maximum SIAINST Record where one exists
	AND (h1.shrapsp_term_code = ( 
	
		SELECT MAX(h2.shrapsp_term_code)
		FROM shrapsp h2
		WHERE h1.shrapsp_pidm = h2.shrapsp_pidm AND h1.shrapsp_stsp_key_sequence = h2.shrapsp_stsp_key_sequence
	
	) OR h1.shrapsp_term_code IS NULL)
	
	-- Limit to active students
	AND f1.sgbstdn_stst_code = 'AS'
	
	-- Limit to active study paths
	AND g1.sgrstsp_stsp_code = 'AS'
	
	-- Limit to current term for enrolment status
	AND d1.sfrensp_term_code = '202001'


	-- Limit to specified programmes
	AND b1.sorlcur_program IN ('BAH-BKF', 'BAH-BTF', 'BAH-BUF', 'BAO-BKF', 'BAO-BTF', 'BAO-BKF', 'BSCH-MYA', 'BENGH-LN', 'BENGO-LN','BSCH-LN', 'BSCO-LN')
	
ORDER BY
	"UMP",
	"Faculty",
	"Campus",
	"Programme",
	"Student_Name"
;