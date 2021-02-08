/*
 * This report identifies students who have more than one outcome record for a study path. 
 * If these are not corrected, then it can cause exam committees and graduation processes to fall over. 
 * A student should only ever have a single outcome record associated with each study path.
 */

SELECT 
	spriden_id AS "Student_Number",
	shrdgmr_pidm AS "PIDM",
	shrdgmr_stsp_key_sequence AS "Study_Path",
	s1.sorlcur_program AS "Programme_Code",
	count(shrdgmr_seq_no) AS "Outcome_Count"
FROM 
	shrdgmr
	JOIN sorlcur s1 ON shrdgmr_pidm = s1.sorlcur_pidm AND shrdgmr_stsp_key_sequence = s1.sorlcur_key_seqno AND s1.sorlcur_lmod_code = 'LEARNER'
	JOIN spriden ON shrdgmr_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
	1=1
	AND shrdgmr_stsp_key_sequence IS NOT NULL
	AND	s1.sorlcur_cact_code = 'ACTIVE'
	AND s1.sorlcur_current_cde = 'Y'
	AND s1.sorlcur_term_code = (
		SELECT MAX(s2.sorlcur_term_code)
		FROM sorlcur s2
		WHERE s1.sorlcur_pidm = s2.sorlcur_pidm AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno AND s2.sorlcur_current_cde = 'Y' AND s2.sorlcur_cact_code = 'ACTIVE'
	)
GROUP BY
	spriden_id,
	shrdgmr_pidm,
	shrdgmr_stsp_key_sequence,
	s1.sorlcur_program
HAVING 
	count(shrdgmr_seq_no) > 1
ORDER BY
	s1.sorlcur_program
;


SELECT * FROM shrdgmr;