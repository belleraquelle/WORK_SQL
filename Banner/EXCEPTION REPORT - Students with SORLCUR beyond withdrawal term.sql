/*
* Students with curricula records beyond withdrawal term
*/

SELECT DISTINCT
	spriden_id,
	sorlcur_program,
	sorlcur_coll_code,
	sfrensp_term_code,
	sfrensp_ests_code,
	sfrensp_ests_date,
	sorlcur_term_code,
	sorlcur_end_date
FROM 
	sfrensp
	JOIN spriden ON sfrensp_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur ON sfrensp_pidm = sorlcur_pidm AND sfrensp_key_seqno = sorlcur_key_seqno
WHERE 
	1=1
	AND sfrensp_term_code IN ('201909','202001','202006')
	AND sfrensp_ests_code = 'WD'
	AND sorlcur_lmod_code = 'LEARNER'
	AND sorlcur_term_code > sfrensp_term_code
ORDER BY 
	sorlcur_coll_code,
	sorlcur_program
;