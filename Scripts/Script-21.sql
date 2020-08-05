SELECT 
	*
FROM
	szrprop
WHERE
	population = '202006-PG-TDE-RESIT'
	AND szrprop_prog_code = 'MSC-QS'
;

SELECT
	d1.spriden_id,
	--a2.shrtckg_pidm, 
	a2.shrtckg_term_code, 
	--a2.shrtckg_tckn_seq_no, 
	c1.shrtckn_crn, 
	c1.shrtckn_subj_code || c1.shrtckn_crse_numb AS "Module_Number",
	a2.shrtckg_grde_code_final
FROM 
	shrtckg a1
	JOIN shrtckg a2 ON a1.shrtckg_pidm = a2.shrtckg_pidm AND a1.shrtckg_term_code = a2.shrtckg_term_code AND a1.shrtckg_tckn_seq_no = a2.shrtckg_tckn_seq_no
	JOIN shrtckn c1 ON a2.shrtckg_pidm = c1.shrtckn_pidm AND a2.shrtckg_term_code = c1.shrtckn_term_code AND a2.shrtckg_tckn_seq_no = c1.shrtckn_seq_no
	JOIN spriden d1 ON a2.shrtckg_pidm = d1.spriden_pidm AND d1.spriden_change_ind IS NULL
WHERE
	1=1
	AND a1.shrtckg_grde_code_final = 'CP'
	AND a2.shrtckg_grde_code_final != 'CP'
	AND a2.shrtckg_seq_no > a1.shrtckg_seq_no
	AND a2.shrtckg_seq_no = 
		(
		SELECT MAX(b1.shrtckg_seq_no)
		FROM shrtckg b1
		WHERE b1.shrtckg_pidm = a2.shrtckg_pidm AND b1.shrtckg_term_code = a2.shrtckg_term_code AND b1.shrtckg_tckn_seq_no = a2.shrtckg_tckn_seq_no
		)
	AND a2.shrtckg_grde_code_final = 'F'
;

SELECT * FROM shrtckn;

SELECT * FROM sorlfos WHERE sorlfos_lfos_rule = '11';