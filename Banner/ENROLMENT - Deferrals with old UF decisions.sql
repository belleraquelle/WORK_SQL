SELECT
	spriden_id,
	a1.saradap_pidm, 
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
WHERE
	1=1
	AND a1.saradap_term_code_entry = '202009'
	--AND a1.saradap_pidm = '1249554'
	AND b1.sarappd_seq_no = (
		SELECT MAX(b2.sarappd_seq_no) 
		FROM sarappd b2 
		WHERE 
			b1.sarappd_pidm = b2.sarappd_pidm
			AND b1.sarappd_appl_no = b2.sarappd_appl_no
		
		)
	AND b1.sarappd_apdc_date < '01-MAY-20'
	AND b1.sarappd_apdc_code = 'UF'
;

SELECT *
FROM shrapsp
WHERE shrapsp_pidm = '1254756'