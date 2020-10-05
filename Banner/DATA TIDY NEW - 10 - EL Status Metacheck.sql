/*
*
* The great EL status metacheck
*
*/


SELECT
	spriden_id,
	sfbetrm_term_code,
	sfbetrm_ests_code,
	sfrensp_key_seqno,
	a1.sorlcur_program,
	sfrensp_ests_code,
	a1.sorlcur_end_date

FROM
	sfbetrm
	JOIN sfrensp ON sfbetrm_pidm = sfrensp_pidm AND sfbetrm_term_code = sfrensp_term_code
	JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur a1 ON a1.sorlcur_pidm = sfrensp_pidm AND a1.sorlcur_key_seqno = sfrensp_key_seqno

WHERE
	1=1
	
	-- Identify the current sorlcur for the study path  
	AND a1.sorlcur_lmod_code = 'LEARNER'
	AND a1.sorlcur_cact_code = 'ACTIVE'
	AND a1.sorlcur_current_cde = 'Y'
	AND a1.sorlcur_term_code = ( 
		
		SELECT MAX(a2.sorlcur_term_code)
		FROM sorlcur a2
		WHERE
			1=1
			AND a1.sorlcur_pidm = a2.sorlcur_pidm
			AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno
			AND a2.sorlcur_lmod_code = 'LEARNER'
			AND a2.sorlcur_cact_code = 'ACTIVE'
			AND a2.sorlcur_current_cde = 'Y'
			
		)

	-- Exclude VSMS programmes
	AND a1.sorlcur_program NOT LIKE ('%-V')
		
	-- Limit to Banner native records
	AND sfbetrm_term_code >= '201909'
	
	-- Identify any EL status records at learner or study path level
	AND (sfbetrm_ests_code = 'EL' OR sfrensp_ests_code = 'EL')
	
	
		
	
ORDER BY 
	spriden_id,
	sfrensp_key_seqno,
	sfbetrm_term_code
;