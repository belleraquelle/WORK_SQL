SELECT 
	b1.spriden_id, 
	b1.spriden_last_name,
	b1.spriden_first_name,
	a1.SARADAP_PROGRAM_1,
	s1.sarappd_apdc_code,
	a2.saradap_program_1,
	t1.sarappd_apdc_code
FROM 
	SARADAP a1 -- Application Table
    JOIN SPRIDEN b1 ON a1.SARADAP_PIDM = b1.SPRIDEN_PIDM AND b1.spriden_change_ind IS NULL
    JOIN SARAPPD s1 ON a1.SARADAP_PIDM = s1.SARAPPD_PIDM AND a1.saradap_term_code_entry = s1.sarappd_term_code_entry AND a1.SARADAP_APPL_NO = s1.SARAPPD_APPL_NO -- Application Decision TABLE
    JOIN saradap a2 ON a1.saradap_pidm = a2.saradap_pidm AND a1.saradap_term_code_entry = a2.saradap_term_code_entry AND a1.saradap_appl_no != a2.saradap_appl_no
    JOIN sarappd t1 ON a2.SARADAP_PIDM = t1.SARAPPD_PIDM AND a2.saradap_term_code_entry = t1.sarappd_term_code_entry AND a2.SARADAP_APPL_NO = t1.SARAPPD_APPL_NO
WHERE 
	1=1


	AND s1.sarappd_seq_no = (
		SELECT MAX(s2.sarappd_seq_no) 
		FROM sarappd s2 
		WHERE 
			s1.sarappd_pidm = s2.sarappd_pidm
			AND s1.sarappd_appl_no = s2.sarappd_appl_no
		)
		
	AND t1.sarappd_seq_no = (
		SELECT MAX(t2.sarappd_seq_no) 
		FROM sarappd t2 
		WHERE 
			t1.sarappd_pidm = t2.sarappd_pidm
			AND t1.sarappd_appl_no = t2.sarappd_appl_no
		
		)
		
	AND s1.sarappd_apdc_code = 'UT'
	AND a1.saradap_apst_code = 'D'
	AND t1.sarappd_apdc_code = 'UT'
	AND a2.saradap_apst_code = 'D'
	AND a1.saradap_term_code_entry = :term_code
;