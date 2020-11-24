
/*
 * This query can be used to identify students enrolled against the specified term who have an unconditional application for the specified term. 
 * It can be used to identify where a deferral might not have been passed through to SRCM for actioning (i.e. withdrawing the student)
 */



SELECT
	spriden_id,
	a1.saradap_pidm, 
	a1.saradap_program_1 "Application_Programme",
	t1.sorlcur_program "Enrolled_Programme",
	a1.saradap_apst_code,
	b1.sarappd_term_code_entry,
	b1.sarappd_appl_no,
	b1.sarappd_apdc_date,
	b1.sarappd_apdc_code
	
FROM 
	saradap a1
	JOIN spriden ON a1.saradap_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sarappd b1 ON 
		a1.saradap_pidm = b1.sarappd_pidm 
		AND a1.saradap_term_code_entry = b1.sarappd_term_code_entry
		AND a1.saradap_appl_no = b1.sarappd_appl_no
	JOIN sfrensp ON saradap_pidm = sfrensp_pidm
	JOIN sorlcur t1 ON sfrensp_pidm = t1.sorlcur_pidm AND sfrensp_key_seqno = t1.sorlcur_key_seqno
WHERE
	1=1
	
	-- SORLCUR requirements  
	AND t1.sorlcur_lmod_code = 'LEARNER'
	AND t1.sorlcur_cact_code = 'ACTIVE'
	AND t1.sorlcur_current_cde = 'Y'
	AND t1.sorlcur_term_code = ( 
		
		SELECT MAX(a2.sorlcur_term_code)
		FROM sorlcur a2
		WHERE
			1=1
			AND t1.sorlcur_pidm = a2.sorlcur_pidm
			AND t1.sorlcur_key_seqno = a2.sorlcur_key_seqno
			AND a2.sorlcur_lmod_code = 'LEARNER'
			AND a2.sorlcur_cact_code = 'ACTIVE'
			AND a2.sorlcur_current_cde = 'Y'
	
		)
	
	
	AND a1.saradap_term_code_entry = :application_term -- The term to check for applications
	--AND a1.saradap_pidm = '1249554'
	AND b1.sarappd_seq_no = (
		SELECT MAX(b2.sarappd_seq_no) 
		FROM sarappd b2 
		WHERE 
			b1.sarappd_pidm = b2.sarappd_pidm
			AND b1.sarappd_appl_no = b2.sarappd_appl_no
		
		)
	AND b1.sarappd_apdc_code = 'UT'
	AND sfrensp_term_code = :enrolment_term -- The term to check for enrolment 
	AND t1.sorlcur_term_code_admit = :enrolment_term
	AND sfrensp_ests_code = 'EN'
;