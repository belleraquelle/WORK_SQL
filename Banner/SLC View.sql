SELECT 
	rkrsslc_pidm,
	CASE
		-- Check for withdrawn students
		WHEN EXISTS (
			SELECT 1
			FROM sfbetrm sfb, stvterm stv
			WHERE 1=1
			AND rkrsslc_pidm=sfb.sfbetrm_pidm
			AND sfb.sfbetrm_term_code = stv.stvterm_code
			AND sfb.SFBETRM_ESTS_CODE IN ('NS', 'WD')
			AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year) THEN 'X'
		-- Check for suspended students
		WHEN EXISTS (
			SELECT 1
			FROM sfbetrm sfb, stvterm stv
			WHERE 1=1
			AND rkrsslc_pidm=sfb.sfbetrm_pidm
			AND sfb.sfbetrm_term_code = stv.stvterm_code
			AND sfb.SFBETRM_ESTS_CODE IN ('AT', 'UT')
			AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year) THEN 'S'
		-- Fees don't match
		WHEN rkrsslc_course_tuition_fee != (
			SELECT  sum(tbraccd_amount)    
            FROM tbraccd
            WHERE 1=1
            AND tbraccd_srce_code ='R'
            AND tbraccd_pidm=rkrsslc_pidm
            AND tbraccd_term_code IN (
            	SELECT stvterm_code
                FROM stvterm 
                WHERE stvterm_fa_proc_yr = rkrsslc_finaid_year)) THEN 'F'
		-- Course not mapped
		WHEN sorlcur_program NOT IN (select SKVSSDT_DATA from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkrsslc_slc_course_code
				union
				select SKVSSDT_DATA_2 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkrsslc_slc_course_code
				union
				select SKVSSDT_DATA_3 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkrsslc_slc_course_code
				union
				select SKVSSDT_SDAT_CODE_OPT_2 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkrsslc_slc_course_code
				union
				select SKVSSDT_SDAT_CODE_OPT_3 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkrsslc_slc_course_code)
				THEN 'C'
		-- Year 0 Check
		WHEN EXISTS (
			SELECT 1
			FROM sfbetrm sfb, stvterm stv
			WHERE 1=1
			AND rkrsslc_pidm=sfb.sfbetrm_pidm
			AND sfb.sfbetrm_term_code = stv.stvterm_code
			AND sfb.SFBETRM_ESTS_CODE IN ('EN')
			AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year)
			AND rkrrsslc_course_year = 0
	END AS "ATFEE_STATUS"
FROM 
	rkrsslc
	JOIN sorlcur ON rkrsslc_pidm = sorlcur_pidm 
		AND sorlcur_cact_code = 'ACTIVE' 
		AND sorlcur_lmod_code = sb_curriculum_str.f_learner
		AND sb_curriculum.f_find_current_all_ind
				(sorlcur_pidm,
				sorlcur_lmod_code,
				sorlcur_term_code,
				sorlcur_key_seqno,
				sorlcur_priority_no,
				sorlcur_seqno,
				NULL, --or term code being queried
				sorlcur_current_cde,
				'N',
				sorlcur_term_code_end) = 'Y'
WHERE
	1=1
	AND rkrsslc_finaid_year = '2021'
	AND rkrsslc_atfe_status = 'A'
ORDER BY "ATFEE_STATUS"
;