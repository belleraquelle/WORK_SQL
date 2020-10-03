SELECT spriden_id, sgbstdn.*
FROM 
	sgbstdn 
		JOIN spriden ON sgbstdn_pidm = spriden_pidm AND spriden_change_ind IS NULL 
WHERE 
	1=1
	AND sgbstdn_resd_code = '0' 
	AND sgbstdn_term_code_eff = '202009' 
	AND sgbstdn_stst_code = 'AS'
	;