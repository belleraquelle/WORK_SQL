SELECT 
	spriden_id,
	spriden_last_name,
	spriden_first_name,
	shrdgmr_pidm, 
	shrdgmr_degc_code,
	shrdgmr_degs_code,
	shrdgih_honr_code,
	shrdgmr_grad_date,
	shrdgmr_program
FROM 
	shrdgmr 
	JOIN spriden ON shrdgmr_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN shrdgih ON shrdgmr_pidm = shrdgih_pidm AND shrdgmr_seq_no = shrdgih_dgmr_seq_no
WHERE
	1=1
	AND shrdgmr_program = 'BSCH-PX'
	AND shrdgmr_grad_date >= '01-JUN-20'
ORDER BY 	
	shrdgmr_grad_date,
	spriden_last_name
;