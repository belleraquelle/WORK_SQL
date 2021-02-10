/*
 * Identifies all students with an RX hold added on or after the specified date.
 */

SELECT DISTINCT
	spriden_id, 
	spriden_last_name, 
	spriden_first_name, 
	sorlcur_term_code_admit,
	sorlcur_program,
	sprhold.*
FROM 
	sprhold
	JOIN spriden ON sprhold_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur s1 ON sprhold_pidm = sorlcur_pidm AND sorlcur_lmod_code = 'LEARNER'
WHERE
	1=1
	AND sprhold_hldd_code = 'RX'
	AND sprhold_to_date > sysdate
	AND sprhold_from_date >= '08-FEB-2021'
	AND s1.sorlcur_term_code_admit = (
		SELECT MAX(s2.sorlcur_term_code_admit) FROM sorlcur s2 WHERE s1.sorlcur_pidm = s2.sorlcur_pidm AND s2.sorlcur_lmod_code = 'LEARNER'
		)
	ORDER BY sorlcur_term_code_admit, sorlcur_program
;