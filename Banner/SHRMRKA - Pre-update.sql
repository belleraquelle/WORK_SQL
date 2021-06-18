SELECT spriden_id, shrmrka_gcom_id, shrmrka_audit_seq_no, shrmrka_score, shrmrka_grde_code, shrmrka_gchg_code
FROM shrmrka 
	JOIN spriden ON shrmrka_pidm = spriden_pidm AND spriden_change_ind IS NULL 
WHERE 
	1=1 
	AND spriden_id = '19133286' 
	AND shrmrka_crn = '15942'
ORDER BY
	shrmrka_gcom_id,
	shrmrka_audit_seq_no