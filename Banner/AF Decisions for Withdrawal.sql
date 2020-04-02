SELECT DISTINCT
	spriden_id,
	shrapsp_term_code,
	shrapsp_astd_code_end_of_term,
	sfrensp1.sfrensp_ests_code,
	sfbetrm1.sfbetrm_rgre_code,
	cur1.sorlcur_program
FROM 
	shrapsp shrapsp1 
	JOIN spriden ON shrapsp_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sfbetrm sfbetrm1 ON shrapsp1.shrapsp_pidm = sfbetrm1.sfbetrm_pidm
	JOIN sfrensp sfrensp1 ON shrapsp1.shrapsp_pidm = sfrensp1.sfrensp_pidm AND shrapsp1.shrapsp_stsp_key_sequence = sfrensp1.sfrensp_key_seqno
	JOIN sorlcur cur1 ON shrapsp1.shrapsp_pidm = cur1.sorlcur_pidm AND shrapsp1.shrapsp_stsp_key_sequence = cur1.sorlcur_key_seqno AND cur1.sorlcur_lmod_code = 'LEARNER'
		AND cur1.sorlcur_term_code = (
			SELECT MAX(cur2.sorlcur_term_code) 
			FROM sorlcur cur2 
			WHERE 
				1=1
				AND cur1.sorlcur_pidm = cur2.sorlcur_pidm 
				AND cur1.sorlcur_key_seqno = cur2.sorlcur_key_seqno
				AND cur2.sorlcur_lmod_code = 'LEARNER'
			)
WHERE
	1=1 
	AND shrapsp1.shrapsp_term_code = (
		SELECT MAX(shrapsp2.shrapsp_term_code)
		FROM shrapsp shrapsp2
		WHERE shrapsp1.shrapsp_pidm = shrapsp2.shrapsp_pidm AND shrapsp1.shrapsp_stsp_key_sequence = shrapsp2.shrapsp_stsp_key_sequence
	)
	AND sfbetrm1.sfbetrm_term_code = (
		SELECT MAX(sfbetrm2.sfbetrm_term_code)
		FROM sfbetrm sfbetrm2
		WHERE sfbetrm1.sfbetrm_pidm = sfbetrm2.sfbetrm_pidm
	)
	AND sfrensp1.sfrensp_term_code = (
		SELECT MAX(sfrensp2.sfrensp_term_code)
		FROM sfrensp sfrensp2
		WHERE sfrensp1.sfrensp_pidm = sfrensp2.sfrensp_pidm AND sfrensp1.sfrensp_key_seqno = sfrensp2.sfrensp_key_seqno
	)
	AND shrapsp1.shrapsp_astd_code_end_of_term = 'AF'
	AND shrapsp1.shrapsp_term_code >= '201809'
ORDER BY
	spriden_id
;