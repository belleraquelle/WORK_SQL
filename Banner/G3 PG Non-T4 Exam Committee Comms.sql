SELECT DISTINCT
	shrapsp_pidm
FROM
	shrapsp
	JOIN sorlcur ON shrapsp_stsp_key_sequence = sorlcur_key_seqno AND shrapsp_pidm = sorlcur_pidm
WHERE
	shrapsp_astd_code_end_of_term = 'G3'
	AND shrapsp_term_code = '201906'
	AND shrapsp_activity_date >= '01-DEC-2019'
	AND sorlcur_levl_code = 'PG'
    AND shrapsp_pidm NOT IN (SELECT gorvisa_pidm FROM gorvisa WHERE gorvisa_vtyp_code = 'T4')