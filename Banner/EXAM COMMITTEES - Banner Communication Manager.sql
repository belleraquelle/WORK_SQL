SELECT DISTINCT
	shrapsp_pidm,
    shrapsp_term_code,
    shrapsp_astd_code_end_of_term,
    shrapsp_prev_code
FROM
	shrapsp
	JOIN sorlcur ON shrapsp_stsp_key_sequence = sorlcur_key_seqno AND shrapsp_pidm = sorlcur_pidm
	JOIN sobcurr_add ON sorlcur_curr_rule = sobcurr_curr_rule
WHERE
    1=1
	--AND shrapsp_astd_code_end_of_term = 'G3'
	--AND shrapsp_term_code = '201909'
	AND shrapsp_activity_date >= '20-FEB-2020'
    --AND shrapsp_pidm NOT IN (SELECT gorvisa_pidm FROM gorvisa WHERE gorvisa_vtyp_code = 'T4')
	AND (ump_1 IS NULL AND sorlcur_program NOT IN ('CHEU','DHEU'))
    AND NOT (shrapsp_astd_code_end_of_term IS NULL AND shrapsp_prev_code IS NULL)
ORDER BY
    shrapsp_astd_code_end_of_term,
    shrapsp_prev_code
;