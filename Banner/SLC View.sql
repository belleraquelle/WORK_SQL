SELECT DISTINCT
	rkrsslc_pidm,
	rkrsslc_acad_year,
	rkrsslc_finaid_year,
	rkrsslc_seq_no,
	s1.sorlcur_program,
	rkrsslc_course_tuition_fee,
	rkrsslc_slc_course_code,
	rkrsslc_course_year,
	s1.sorlcur_term_code_admit,
	s1.sorlcur_key_seqno,
	CASE
		-- Check for withdrawn students
		WHEN EXISTS (
			SELECT 1
			FROM sfbetrm sfb, stvterm stv
			WHERE 1=1
			AND rkrsslc_pidm=sfb.sfbetrm_pidm
			AND sfb.sfbetrm_term_code = stv.stvterm_code
			AND sfb.SFBETRM_ESTS_CODE IN ('NS', 'WD')
			AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year) THEN 'WITHDRAWN (X)'
		-- Check for suspended students
		WHEN EXISTS (
			SELECT 1
			FROM sfbetrm sfb, stvterm stv
			WHERE 1=1
			AND rkrsslc_pidm=sfb.sfbetrm_pidm
			AND sfb.sfbetrm_term_code = stv.stvterm_code
			AND sfb.SFBETRM_ESTS_CODE IN ('AT', 'UT')
			AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year) THEN 'SUSPENDED (S)'
		-- Check for fee mismatch
		WHEN rkrsslc_course_tuition_fee != (
			SELECT  sum(tbraccd_amount)    
            FROM tbraccd
            WHERE 1=1
            AND tbraccd_srce_code ='R'
            AND tbraccd_pidm=rkrsslc_pidm
            AND tbraccd_term_code IN (
            	SELECT stvterm_code
                FROM stvterm 
                WHERE stvterm_fa_proc_yr = rkrsslc_finaid_year)) THEN 'FEES MISMATCH (F)'
		-- Check for unmapped courses
		WHEN s1.sorlcur_program NOT IN (select SKVSSDT_DATA from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkrsslc_slc_course_code
				union
				select SKVSSDT_DATA_2 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkrsslc_slc_course_code
				union
				select SKVSSDT_DATA_3 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkrsslc_slc_course_code
				union
				select SKVSSDT_SDAT_CODE_OPT_2 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkrsslc_slc_course_code
				union
				select SKVSSDT_SDAT_CODE_OPT_3 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkrsslc_slc_course_code)
				THEN 'COURSE NOT MAPPED (C)'
		-- Check for valid Year 0 entries
		WHEN 
			EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE 1=1
				AND rkrsslc_pidm=sfb.sfbetrm_pidm
				AND sfb.sfbetrm_term_code = stv.stvterm_code
				AND sfb.SFBETRM_ESTS_CODE IN ('EN')
				AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
				)	
			AND rkrsslc_course_year = 0
			AND EXISTS (
				SELECT 1
				FROM sgrsatt sgr1
				WHERE 
					sgr1.sgrsatt_pidm = rkrsslc_pidm 
					AND sgr1.sgrsatt_term_code_eff = (
						SELECT MAX(sgr2.sgrsatt_term_code_eff)
						FROM sgrsatt sgr2
						WHERE 
							sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
							AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
							-- Limit to attribute records that started on or before the CURRENT term
							AND sgr2.sgrsatt_term_code_eff <= (SELECT stvterm_code AS "Current Term" FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
					)
					AND sgrsatt_atts_code IN ('S1')
				)
		THEN 'YEAR 0 (A)'
		-- Check for valid Year 1 records
		WHEN 
			EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE 1=1
				AND rkrsslc_pidm=sfb.sfbetrm_pidm
				AND sfb.sfbetrm_term_code = stv.stvterm_code
				AND sfb.SFBETRM_ESTS_CODE IN ('EN')
				AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
				)
			AND rkrsslc_course_year = 1
			AND EXISTS (
				SELECT 1
				FROM sgrsatt sgr1
				WHERE 
					sgr1.sgrsatt_pidm = rkrsslc_pidm 
					AND sgr1.sgrsatt_term_code_eff = (
						SELECT MAX(sgr2.sgrsatt_term_code_eff)
						FROM sgrsatt sgr2
						WHERE 
							sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
							AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
							AND '202106' >= sgr2.sgrsatt_term_code_eff
					)
					AND sgrsatt_atts_code IN ('S1', 'X1')
				)
		THEN 'YEAR 1 (A)'
		-- Check for valid Year 2 records
		WHEN 
			EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE 1=1
				AND rkrsslc_pidm=sfb.sfbetrm_pidm
				AND sfb.sfbetrm_term_code = stv.stvterm_code
				AND sfb.SFBETRM_ESTS_CODE IN ('EN')
				AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
				)
			AND rkrsslc_course_year = 2
			AND EXISTS (
				SELECT 1
				FROM sgrsatt sgr1
				WHERE 
					sgr1.sgrsatt_pidm = rkrsslc_pidm 
					AND sgr1.sgrsatt_term_code_eff = (
						SELECT MAX(sgr2.sgrsatt_term_code_eff)
						FROM sgrsatt sgr2
						WHERE 
							sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
							AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
							-- Limit to attribute records that started on or before the CURRENT term
							AND sgr2.sgrsatt_term_code_eff <= (SELECT stvterm_code AS "Current Term" FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
					)
					AND sgrsatt_atts_code IN ('S2', 'X2', 'X2A', 'SW')
				)
		THEN 'YEAR 2 (A)'
		-- Check for valid Year 3 records (pre-framework)
		WHEN 
			s1.sorlcur_term_code_admit < '202009' -- It is okay for this value to be hardcoded. 202009 is when the new framework came into effect for new entrants.
			AND EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE
					rkrsslc_pidm=sfb.sfbetrm_pidm
					AND sfb.sfbetrm_term_code = stv.stvterm_code
					AND sfb.SFBETRM_ESTS_CODE IN ('EN')
					AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
				)
			AND EXISTS(
				SELECT 1
				FROM sgrsatt sgr1
				WHERE 
					sgr1.sgrsatt_pidm = rkrsslc_pidm 
					AND sgr1.sgrsatt_term_code_eff = (
						SELECT MAX(sgr2.sgrsatt_term_code_eff)
						FROM sgrsatt sgr2
						WHERE 
							sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
							AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
							-- Limit to attribute records that started on or before the CURRENT term
							AND sgr2.sgrsatt_term_code_eff <= (SELECT stvterm_code AS "Current Term" FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
					)
					AND sgrsatt_atts_code IN ('S2', 'X2')
				) 
			AND rkrsslc_course_year = 3
			AND EXISTS (
				SELECT 1
				FROM shrapsp shra1, stvterm stv
				WHERE
					shra1.shrapsp_pidm = rkrsslc_pidm
					AND s1.sorlcur_key_seqno = shra1.shrapsp_stsp_key_sequence
					AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
					AND stv.stvterm_fa_term = 1
					AND shra1.shrapsp_term_code = (
						SELECT MAX(shrapsp_term_code)
						FROM shrapsp
						WHERE 
							shrapsp_pidm = rkrsslc_pidm
							AND shrapsp_stsp_key_sequence = s1.sorlcur_key_seqno
							AND shrapsp_term_code < stv.stvterm_code
							AND shrapsp_astd_code_end_of_term IS NOT NULL
						)
					AND shra1.shrapsp_astd_code_end_of_term IN ('P1','P2','T1','G1')
			)
		THEN 'YEAR 3 PRE-AFR (A)'
		-- Check for valid Year 3 records (SW and S3 pre-framework)
		WHEN 
			s1.sorlcur_term_code_admit < '202009' -- It is okay for this value to be hardcoded. 202009 is when the new framework came into effect for new entrants.
			AND EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE 1=1
				AND rkrsslc_pidm=sfb.sfbetrm_pidm
				AND sfb.sfbetrm_term_code = stv.stvterm_code
				AND sfb.SFBETRM_ESTS_CODE IN ('EN')
				AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year)
			AND rkrsslc_course_year = 3
			AND EXISTS(
				SELECT 1
				FROM sgrsatt sgr1
				WHERE 
					sgr1.sgrsatt_pidm = rkrsslc_pidm 
					AND sgr1.sgrsatt_term_code_eff = (
						SELECT MAX(sgr2.sgrsatt_term_code_eff)
						FROM sgrsatt sgr2
						WHERE 
							sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
							AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
							-- Limit to attribute records that started on or before the CURRENT term
							AND sgr2.sgrsatt_term_code_eff <= (SELECT stvterm_code AS "Current Term" FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
						)
					AND sgrsatt_atts_code IN ('SW', 'S3')
				)
		THEN 'YEAR 3 PRE-AFR (A)'
		-- Check for valid Year 3 records (post-framework)
		WHEN 
			s1.sorlcur_term_code_admit >= '202009' -- It is okay for this value to be hardcoded. 202009 is when the new framework came into effect for new entrants.
			AND EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE 1=1
				AND rkrsslc_pidm=sfb.sfbetrm_pidm
				AND sfb.sfbetrm_term_code = stv.stvterm_code
				AND sfb.SFBETRM_ESTS_CODE IN ('EN')
				AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
				)
			AND rkrsslc_course_year = 3
			AND EXISTS(
				SELECT 1
				FROM sgrsatt sgr1
				WHERE 
					sgr1.sgrsatt_pidm = rkrsslc_pidm 
					AND sgr1.sgrsatt_term_code_eff = (
						SELECT MAX(sgr2.sgrsatt_term_code_eff)
						FROM sgrsatt sgr2
						WHERE 
							sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
							AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
							-- Limit to attribute records that started on or before the CURRENT term
							AND sgr2.sgrsatt_term_code_eff <= (SELECT stvterm_code AS "Current Term" FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
					)
					AND sgrsatt_atts_code IN ('SW', 'S3', 'X3A')
				)
		THEN 'YEAR 3 POST-AFR (A)'
		-- Check for valid Year 4 records (pre-framework)
		WHEN 
			s1.sorlcur_term_code_admit < '202009' -- It is okay for this value to be hardcoded. 202009 is when the new framework came into effect for new entrants.
			AND EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE
					rkrsslc_pidm=sfb.sfbetrm_pidm
					AND sfb.sfbetrm_term_code = stv.stvterm_code
					AND sfb.SFBETRM_ESTS_CODE IN ('EN')
					AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
				)
			AND EXISTS(
				SELECT 1
				FROM sgrsatt sgr1
				WHERE 
					sgr1.sgrsatt_pidm = rkrsslc_pidm 
					AND sgr1.sgrsatt_term_code_eff = (
						SELECT MAX(sgr2.sgrsatt_term_code_eff)
						FROM sgrsatt sgr2
						WHERE 
							sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
							AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
							-- Limit to attribute records that started on or before the CURRENT term
							AND sgr2.sgrsatt_term_code_eff <= (SELECT stvterm_code AS "Current Term" FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
					)
					AND sgrsatt_atts_code IN ('X2')
				) 
			AND rkrsslc_course_year = 4
			AND EXISTS(
				SELECT 1
				FROM shrapsp shra1, stvterm stv
				WHERE
					shra1.shrapsp_pidm = rkrsslc_pidm
					AND s1.sorlcur_key_seqno = shra1.shrapsp_stsp_key_sequence
					AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
					AND stv.stvterm_fa_term = 1
					AND shra1.shrapsp_term_code = (
						SELECT MAX(shrapsp_term_code)
						FROM shrapsp
						WHERE 
							shrapsp_pidm = rkrsslc_pidm
							AND shrapsp_stsp_key_sequence = s1.sorlcur_key_seqno
							AND shrapsp_term_code < stv.stvterm_code
							AND shrapsp_astd_code_end_of_term IS NOT NULL
						)
					AND shra1.shrapsp_astd_code_end_of_term IN ('P1','P2','T1','G1')
			)
		THEN 'YEAR 4 PRE-AFR (A)'
		-- Check for valid Year 4 records (XM pre-framework)
		WHEN 
			s1.sorlcur_term_code_admit < '202009' -- It is okay for this value to be hardcoded. 202009 is when the new framework came into effect for new entrants.
			AND EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE 1=1
				AND rkrsslc_pidm=sfb.sfbetrm_pidm
				AND sfb.sfbetrm_term_code = stv.stvterm_code
				AND sfb.SFBETRM_ESTS_CODE IN ('EN')
				AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year)
			AND rkrsslc_course_year = 4
			AND EXISTS(
				SELECT 1
				FROM sgrsatt sgr1
				WHERE 
					sgr1.sgrsatt_pidm = rkrsslc_pidm 
					AND sgr1.sgrsatt_term_code_eff = (
						SELECT MAX(sgr2.sgrsatt_term_code_eff)
						FROM sgrsatt sgr2
						WHERE 
							sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
							AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
							-- Limit to attribute records that started on or before the CURRENT term
							AND sgr2.sgrsatt_term_code_eff <= (SELECT stvterm_code AS "Current Term" FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
						)
					AND sgrsatt_atts_code IN ('XM')
				)
		THEN 'YEAR 4 PRE-AFR (A)'
		-- Check for valid Year 4 records (post-framework)
		WHEN 
			s1.sorlcur_term_code_admit >= '202009' -- It is okay for this value to be hardcoded. 202009 is when the new framework came into effect for new entrants.
			AND EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE 1=1
				AND rkrsslc_pidm=sfb.sfbetrm_pidm
				AND sfb.sfbetrm_term_code = stv.stvterm_code
				AND sfb.SFBETRM_ESTS_CODE IN ('EN')
				AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year)
				AND rkrsslc_course_year = 4
				AND EXISTS(
					SELECT 1
					FROM sgrsatt sgr1
					WHERE 
						sgr1.sgrsatt_pidm = rkrsslc_pidm 
						AND sgr1.sgrsatt_term_code_eff = (
							SELECT MAX(sgr2.sgrsatt_term_code_eff)
							FROM sgrsatt sgr2
							WHERE 
								sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
								AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
								AND '202106' >= sgr2.sgrsatt_term_code_eff
						)
						AND sgrsatt_atts_code IN ('X3A','XM')
				)
		THEN 'YEAR 4 POST-AFR (A)'
		-- Check for valid Year 5 records (pre-framework)
		WHEN 
			s1.sorlcur_term_code_admit < '202009' -- It is okay for this value to be hardcoded. 202009 is when the new framework came into effect for new entrants.
			AND EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE
					rkrsslc_pidm=sfb.sfbetrm_pidm
					AND sfb.sfbetrm_term_code = stv.stvterm_code
					AND sfb.SFBETRM_ESTS_CODE IN ('EN')
					AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
				)
			AND EXISTS(
				SELECT 1
				FROM sgrsatt sgr1
				WHERE 
					sgr1.sgrsatt_pidm = rkrsslc_pidm 
					AND sgr1.sgrsatt_term_code_eff = (
						SELECT MAX(sgr2.sgrsatt_term_code_eff)
						FROM sgrsatt sgr2
						WHERE 
							sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
							AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
							-- Limit to attribute records that started on or before the CURRENT term
							AND sgr2.sgrsatt_term_code_eff <= (SELECT stvterm_code AS "Current Term" FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
					)
					AND sgrsatt_atts_code IN ('XM')
				) 
			AND rkrsslc_course_year = 5
			AND EXISTS (
				SELECT 1
				FROM shrapsp shra1, stvterm stv
				WHERE
					shra1.shrapsp_pidm = rkrsslc_pidm
					AND s1.sorlcur_key_seqno = shra1.shrapsp_stsp_key_sequence
					AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
					AND stv.stvterm_fa_term = 1
					AND shra1.shrapsp_term_code = (
						SELECT MAX(shrapsp_term_code)
						FROM shrapsp
						WHERE 
							shrapsp_pidm = rkrsslc_pidm
							AND shrapsp_stsp_key_sequence = s1.sorlcur_key_seqno
							AND shrapsp_term_code < stv.stvterm_code
							AND shrapsp_astd_code_end_of_term IS NOT NULL
						)
					AND shra1.shrapsp_astd_code_end_of_term IN ('P1','P2','T1','G1')
			)
		THEN 'YEAR 5 PRE-AFR (A)'
		-- Check for valid Year 5 records (post-framework)
		WHEN 
			s1.sorlcur_term_code_admit >= '202009' -- It is okay for this value to be hardcoded. 202009 is when the new framework came into effect for new entrants.
			AND EXISTS (
				SELECT 1
				FROM sfbetrm sfb, stvterm stv
				WHERE 1=1
				AND rkrsslc_pidm=sfb.sfbetrm_pidm
				AND sfb.sfbetrm_term_code = stv.stvterm_code
				AND sfb.SFBETRM_ESTS_CODE IN ('EN')
				AND stv.stvterm_fa_proc_yr = rkrsslc_finaid_year)
				AND rkrsslc_course_year = 5
				AND EXISTS(
					SELECT 1
					FROM sgrsatt sgr1
					WHERE 
						sgr1.sgrsatt_pidm = rkrsslc_pidm 
						AND sgr1.sgrsatt_term_code_eff = (
							SELECT MAX(sgr2.sgrsatt_term_code_eff)
							FROM sgrsatt sgr2
							WHERE 
								sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm 
								AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
								-- Limit to attribute records that started on or before the CURRENT term
							AND sgr2.sgrsatt_term_code_eff <= (SELECT stvterm_code AS "Current Term" FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
						)
						AND sgrsatt_atts_code IN ('XM')
				)
		THEN 'YEAR 4 POST-AFR (A)'
		ELSE 'No hits (C))'
	END AS "ATFEE_STATUS"
FROM 
	rkrsslc
	JOIN sorlcur s1 ON rkrsslc_pidm = s1.sorlcur_pidm
WHERE
	1=1
	AND rkrsslc_finaid_year = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc) -- Current year in the SLC table
	--AND rkrsslc_atfe_status = 'A'
	AND s1.sorlcur_cact_code = 'ACTIVE' 
	AND s1.sorlcur_lmod_code = 'LEARNER'
	AND s1.sorlcur_current_cde = 'Y' 
	AND s1.sorlcur_term_code = (
		SELECT MAX(s2.sorlcur_term_code)
		FROM sorlcur s2
		WHERE 
			s1.sorlcur_pidm = s2.sorlcur_pidm
			AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno
			AND s1.sorlcur_cact_code = s2.sorlcur_cact_code
			AND s1.sorlcur_current_cde = s2.sorlcur_current_cde
			AND s1.sorlcur_lmod_code = s2.sorlcur_lmod_code
			-- Limit the return to records that have a term code less than or equal to the current term (the term that sysdate falls in)
			AND s2.sorlcur_term_code <= (SELECT MAX(stvterm_code) FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
		)
	AND s1.sorlcur_coll_code != 'AS'
	-- End term of curricula record is greater than or equal to the first term of the current finaid year
	AND (SELECT stvterm_code FROM stvterm WHERE s1.sorlcur_end_date BETWEEN stvterm_start_date AND stvterm_end_date) 
		>= (SELECT stvterm_code FROM stvterm WHERE stvterm_fa_proc_yr = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc) AND stvterm_fa_term = 1)
	AND rkrsslc_pidm = '1701503'
ORDER BY "ATFEE_STATUS"
;