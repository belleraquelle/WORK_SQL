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
		-- Courses don't match
		WHEN EXISTS (
			select 1
			from RKRSSLC rkr
			,sfbetrm sfb
			,stvterm stv
			,stvterm stv1
			,stvterm stv2
			,sorlcur sor
			,skvssdt sdt   --Added on 31Oct19
			where 1=1
				and rkr.RKRSSLC_PIDM = rkr1.RKRSSLC_PIDM
				and rkr.RKRSSLC_ACAD_YEAR = rkr1.RKRSSLC_ACAD_YEAR
				and rkr.RKRSSLC_SEQ_NO = rkr1.RKRSSLC_SEQ_NO
				and rkr.rkrsslc_pidm = sfb.sfbetrm_pidm
				and sfb.sfbetrm_term_code = stv.stvterm_code
				and sfb.SFBETRM_ESTS_CODE = 'EN'
				and stv.stvterm_fa_proc_yr = rkrsslc_finaid_year
				and stv1.stvterm_fa_proc_yr = rkrsslc_finaid_year
				and stv1.STVTERM_FA_TERM = 1
				and stv2.stvterm_fa_proc_yr = rkrsslc_finaid_year
				and stv2.STVTERM_FA_TERM = 3
				and rkr.rkrsslc_pidm = sor.sorlcur_pidm
				and sor.sorlcur_cact_code = 'ACTIVE'
				and sor.sorlcur_lmod_code = sb_curriculum_str.f_learner
				and sb_curriculum.f_find_current_all_ind
				(sor.sorlcur_pidm,
				sor.sorlcur_lmod_code,
				sor.sorlcur_term_code,
				sor.sorlcur_key_seqno,
				sor.sorlcur_priority_no,
				sor.sorlcur_seqno,
				NULL, --or term code being queried
				sor.sorlcur_current_cde,
				'N',
				sor.sorlcur_term_code_end) = 'Y'
				and sdt.skvssdt_sdat_code_entity='ESC_SLC'
				and sdt.skvssdt_sdat_code_attr='COURSE_CODE'
				and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code
				and sor.sorlcur_program  not in (select SKVSSDT_DATA from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code
				union
				select SKVSSDT_DATA_2 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code
				union
				select SKVSSDT_DATA_3 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code
				union
				select SKVSSDT_SDAT_CODE_OPT_2 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code
				union
				select SKVSSDT_SDAT_CODE_OPT_3 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code)
				and F_CVT_TERM_CODE_OBU(sor.sorlcur_end_date) >= sfb.sfbetrm_term_code) THEN 'C'
	END AS "ATFEE_STATUS"
FROM 
	rkrsslc
WHERE
	1=1
	AND rkrsslc_finaid_year = '2021'
	AND rkrsslc_atfe_status = 'A'
ORDER BY "ATFEE_STATUS"
;


SELECT 
	*
FROM 
	rkrsrul
WHERE
	1=1
	AND rkrsrul_finaid_year = '2021'
	AND rkrsrul_srtp_code = 'ATFEE UPDATE'
ORDER BY
	rkrsrul_priority_no
;

SELECT * 
FROM rkrsslc WHERE rkrsslc_finaid_year = '2021' AND rkrsslc_atfe_status = 'A';

SELECT spriden_id FROM spriden WHERE spriden_pidm = '1701790';

SELECT * FROM stvterm ORDER BY stvterm_code;

UPDATE rkrsslc rkr1
SET rkrsslc_atfe_statuS= 'A', rkrsslc_atfe_status_date = sysdate
WHERE rkrsslc_file_type = 'ATFEE'
AND rkrsslc_finaid_year = '2021' 
AND rkrsslc_pidm = :pidm
AND EXISTS (select 1
from RKRSSLC rkr
,sfbetrm sfb
,stvterm stv
,stvterm stv1
,stvterm stv2
,sorlcur sor
,sgrsatt att1
,sgrsatt att2
,skvssdt sdt   --Added on 31Oct19
where 1=1
and rkr.RKRSSLC_PIDM = rkr1.RKRSSLC_PIDM
and rkr.RKRSSLC_ACAD_YEAR = rkr1.RKRSSLC_ACAD_YEAR
and rkr.RKRSSLC_SEQ_NO = rkr1.RKRSSLC_SEQ_NO
and rkr.rkrsslc_pidm = sfb.sfbetrm_pidm
and sfb.sfbetrm_term_code = stv.stvterm_code
and sfb.SFBETRM_ESTS_CODE = 'EN'
and stv.stvterm_fa_proc_yr = '2021'
and stv1.stvterm_fa_proc_yr = '2021'
and stv1.STVTERM_FA_TERM = 1
and stv2.stvterm_fa_proc_yr = '2021'
and stv2.STVTERM_FA_TERM = 3
and rkr.RKRSSLC_PIDM = att1.sgrsatt_pidm(+)
and att1.SGRSATT_STSP_KEY_SEQUENCE(+) = sor.sorlcur_key_seqno
and rkr.RKRSSLC_PIDM = att2.sgrsatt_pidm
and att2.SGRSATT_STSP_KEY_SEQUENCE = sor.sorlcur_key_seqno
and att1.sgrsatt_term_code_eff =
(select max(sgrsatt_term_code_eff)
from sgrsatt
where 1=1
and sgrsatt_pidm = rkr.RKRSSLC_PIDM
and SGRSATT_STSP_KEY_SEQUENCE = sor.sorlcur_key_seqno
and sgrsatt_term_code_eff <= stv1.stvterm_code)
and att2.sgrsatt_term_code_eff = 
(select max(sgrsatt_term_code_eff)
from sgrsatt
where 1=1
and sgrsatt_pidm = rkr.RKRSSLC_PIDM
and SGRSATT_STSP_KEY_SEQUENCE = sor.sorlcur_key_seqno
and sgrsatt_term_code_eff <= stv2.stvterm_code)
and (att1.sgrsatt_atts_code ='S1' or (att1.sgrsatt_pidm is null and att2.sgrsatt_atts_code='S1'))
and rkr.rkrsslc_pidm = sor.sorlcur_pidm
and sor.sorlcur_cact_code = 'ACTIVE'
and sor.sorlcur_lmod_code = sb_curriculum_str.f_learner
and sb_curriculum.f_find_current_all_ind
(sor.sorlcur_pidm,
sor.sorlcur_lmod_code,
sor.sorlcur_term_code,
sor.sorlcur_key_seqno,
sor.sorlcur_priority_no,
sor.sorlcur_seqno,
NULL, --or term code being queried
sor.sorlcur_current_cde,'N',
sor.sorlcur_term_code_end) = 'Y'
and rkr.RKRSSLC_COURSE_YEAR = 0
and sdt.skvssdt_sdat_code_entity='ESC_SLC'
and sdt.skvssdt_sdat_code_attr='COURSE_CODE'
and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code
--Added below on 10Dec19
and sor.sorlcur_program  in (select SKVSSDT_DATA from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code
union
select SKVSSDT_DATA_2 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code
union
select SKVSSDT_DATA_3 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code
union
select SKVSSDT_SDAT_CODE_OPT_2 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code
union
select SKVSSDT_SDAT_CODE_OPT_3 from skvssdt where 1=1 and skvssdt_sdat_code_entity='ESC_SLC' and skvssdt_sdat_code_attr='COURSE_CODE' and skvssdt_sdat_code_opt_1=rkr.rkrsslc_slc_course_code)
and F_CVT_TERM_CODE_OBU(sor.sorlcur_end_date) >= sfb.sfbetrm_term_code   ---Changes end					   
and rkr.RKRSSLC_COURSE_TUITION_FEE =
(select  sum(tbraccd_amount)
from tbraccd
where 1=1
and TBRACCD_SRCE_CODE ='R'
and tbraccd_pidm=rkr.rkrsslc_pidm
and tbraccd_term_code in 
(select stvterm_code
from stvterm 
where 1=1
and stvterm_fa_proc_yr=rkr.rkrsslc_finaid_year)))
