select
    LPAD( goksels.f_name_bio_value(a.pidm,'ID'),8,0) AS id,
    a."PIDM",a."FINAID_YEAR",a."PROGRAM",a."KEY_SEQNO",a."TERM_CODE",a."ATFEE_STATUS", a."SSLC_SEQ_NO", a.rkrsslc_slc_course_code
from (
    SELECT
        rkrsslc_pidm pidm,
    -- 	rkrsslc_acad_year,
    	rkrsslc_finaid_year finaid_year,
     	rkrsslc_seq_no sslc_seq_no,
        s1.sorlcur_program program,
    -- 	rkrsslc_course_tuition_fee,
     	rkrsslc_slc_course_code,
    -- 	rkrsslc_course_year,
    -- 	s1.sorlcur_term_code_admit,
        s1.sorlcur_key_seqno key_seqno,
    --     atts.atts_code,
    --     ests.status,
        ests.term_code,
        ( CASE
            WHEN
                ests.status = 'WITHDRAWN'
                THEN 'WITHDRAWN'
            WHEN
                ests.status = 'SUSPENDED'
                THEN 'SUSPENDED'
            WHEN
                rkrsslc_course_tuition_fee != accd.amount
                THEN 'FEES_MISMATCH'
            WHEN
                cm.course_code IS NULL
                THEN 'COURSE_NOT_MAPPED'
            WHEN
                rkrsslc_course_year = 0
                AND atts.atts_code = 'S1'
                THEN 'YEAR_0_A'
            WHEN
                rkrsslc_course_year = 1
                AND atts.atts_code IN ('S1', 'X1')
                THEN 'YEAR_1_A'
            WHEN
                rkrsslc_course_year = 2
                AND atts.atts_code IN ('S2', 'X2', 'X2A', 'SW')
                THEN 'YEAR_2_A'
            WHEN
                rkrsslc_course_year = 3
                AND s1.sorlcur_term_code_admit < '202009'
                AND ests.status = 'ENROLLED'
                AND apsp.eot IN ('P1','P2','T1','G1')
                THEN 'YEAR_3_PRE_AFR_A' -- Check for valid Year 3 records (pre-framework)
            WHEN
                rkrsslc_course_year = 3
                AND s1.sorlcur_term_code_admit < '202009'
                AND ests.status = 'ENROLLED'
                AND atts.atts_code IN ('SW', 'S3')
                THEN 'YEAR_3_PRE_AFR_A' -- Check for valid Year 3 records (SW and S3 pre-framework)
            WHEN
                rkrsslc_course_year = 3
                AND s1.sorlcur_term_code_admit >= '202009'
                AND ests.status = 'ENROLLED'
                AND atts.atts_code IN ('SW', 'S3')
                THEN 'YEAR_3_POST_AFR_A' -- Check for valid Year 3 records (post-framework)
            WHEN
                rkrsslc_course_year = 4
                AND s1.sorlcur_term_code_admit < '202009'
                AND ests.status = 'ENROLLED'
                AND atts.atts_code = 'X2'
                AND apsp.eot IN ('P1','P2','T1','G1')
                THEN 'YEAR_4_PRE_AFR_A' -- Check for valid Year 4 records (pre-framework)
            WHEN
                rkrsslc_course_year = 4
                AND s1.sorlcur_term_code_admit < '202009'
                AND ests.status = 'ENROLLED'
                AND atts.atts_code = 'XM'
                THEN 'YEAR_4_PRE_AFR_A' -- Check for valid Year 4 records (XM pre-framework)
            WHEN
                rkrsslc_course_year = 4
                AND s1.sorlcur_term_code_admit >= '202009'
                AND ests.status = 'ENROLLED'
                AND atts.atts_code IN ('X3A','XM')
                AND atts.term_code_eff >= '202106'
                THEN 'YEAR_4_POST_AFR_A' -- Check for valid Year 4 records (post-framework)'
            WHEN
                rkrsslc_course_year = 5
                AND s1.sorlcur_term_code_admit < '202009'
                AND ests.status = 'ENROLLED'
                AND atts.atts_code = 'XM'
                AND apsp.eot IN ('P1','P2','T1','G1')
                THEN 'YEAR_5_PRE_AFR_A' -- Check for valid Year 5 records (pre-framework)
            WHEN
                rkrsslc_course_year = 5
                AND s1.sorlcur_term_code_admit >= '202009'
                AND ests.status = 'ENROLLED'
                AND atts.atts_code = 'XM'
                THEN 'YEAR_5_POST_AFR_A' -- Check for valid Year 5 records (post-framework)
            ELSE 'NO_HITS'
        END
        ) ATFEE_STATUS
    FROM rkrsslc
    JOIN stvterm ON sysdate BETWEEN stvterm_start_date AND stvterm_end_date
    -- presuming everyone has rows in tbraccd, if not make LEFT JOIN
    LEFT JOIN (
        SELECT  sum(tbraccd_amount) amount,
                tbraccd_pidm pidm
        FROM tbraccd
        WHERE
            tbraccd_srce_code ='R'
            AND tbraccd_term_code IN (
                SELECT stvterm_code
                FROM stvterm
                WHERE stvterm_fa_proc_yr = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc)
            )
        group by tbraccd_pidm
    ) accd ON accd.pidm = rkrsslc_pidm
    -- presuming everyone has rows in sfbetrm, if not make LEFT JOIN
    LEFT JOIN (
        SELECT
           sfb.sfbetrm_pidm pidm,
           sfb.sfbetrm_term_code term_code,
           (CASE
                WHEN sfb.SFBETRM_ESTS_CODE IN ('AT', 'UT') THEN 'SUSPENDED'
                WHEN sfb.SFBETRM_ESTS_CODE IN ('NS', 'WD', 'XF') THEN 'WITHDRAWN'
                WHEN sfb.SFBETRM_ESTS_CODE IN ('EN') THEN 'ENROLLED'
            END) status
        FROM sfbetrm sfb
        WHERE sfb.SFBETRM_ESTS_CODE IN ('NS', 'WD','AT', 'UT','EN')
    ) ests on
        ests.pidm = rkrsslc_pidm
        and ests.term_code = stvterm_code
--         and ests.term_code IN (
--             SELECT stvterm_code
--             FROM stvterm
--             WHERE stvterm_fa_proc_yr = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc)
--         )
    
    LEFT JOIN (
        SELECT
           DISTINCT course_code, skvssdt_sdat_code_opt_1
        FROM
        (
            SELECT
               SKVSSDT_DATA,
               SKVSSDT_DATA_2,
               SKVSSDT_DATA_3,
               SKVSSDT_SDAT_CODE_OPT_2,
               SKVSSDT_SDAT_CODE_OPT_3,
               skvssdt_sdat_code_opt_1
            from skvssdt 
            WHERE
                skvssdt_sdat_code_entity='ESC_SLC'
                and skvssdt_sdat_code_attr='COURSE_CODE'
        ) T UNPIVOT (course_code FOR COL IN (
        -- ok because select is very static table, inverts cols to rows
               SKVSSDT_DATA,
               SKVSSDT_DATA_2,
               SKVSSDT_DATA_3,
               SKVSSDT_SDAT_CODE_OPT_2,
               SKVSSDT_SDAT_CODE_OPT_3)
        )
    ) cm on
        rkrsslc_slc_course_code = skvssdt_sdat_code_opt_1
    LEFT JOIN sorlcur s1 ON rkrsslc_pidm = s1.sorlcur_pidm AND cm.course_code = s1.sorlcur_program
    JOIN (
        SELECT
            sgr1.sgrsatt_pidm pidm,
            sgr1.sgrsatt_atts_code atts_code,
            sgr1.sgrsatt_term_code_eff term_code_eff,
            sgr1.sgrsatt_stsp_key_sequence KEY_SEQNO
        FROM sgrsatt sgr1
        WHERE
            sgr1.sgrsatt_term_code_eff = (
                SELECT MAX(sgr2.sgrsatt_term_code_eff)
                FROM sgrsatt sgr2
                WHERE
                    sgr1.sgrsatt_pidm = sgr2.sgrsatt_pidm
                    AND sgr1.sgrsatt_stsp_key_sequence = sgr2.sgrsatt_stsp_key_sequence
                    -- Limit to attribute records that started on or before the CURRENT term
                    AND sgr2.sgrsatt_term_code_eff <= (SELECT stvterm_code FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
            )
    ) atts on
        atts.pidm = rkrsslc_pidm
        and SORLCUR_KEY_SEQNO = atts.KEY_SEQNO
        LEFT JOIN (
        SELECT
            shra1.shrapsp_pidm pidm,
            shra1.shrapsp_stsp_key_sequence KEY_SEQNO,
            shra1.shrapsp_astd_code_end_of_term eot
        FROM shrapsp shra1, stvterm stv
        WHERE
            stv.stvterm_fa_proc_yr = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc)
            AND stv.stvterm_fa_term = 1
            AND shra1.shrapsp_astd_code_end_of_term IS NOT NULL
            AND shra1.shrapsp_term_code = (
                SELECT MAX(shrapsp_term_code)
                FROM shrapsp shra2
                WHERE
                    shra2.shrapsp_pidm = shra1.shrapsp_pidm
                    AND shra2.shrapsp_term_code < stv.stvterm_code
                    AND shra2.shrapsp_astd_code_end_of_term IS NOT NULL
                )
    ) apsp on
        apsp.KEY_SEQNO = s1.sorlcur_key_seqno
        AND apsp.PIDM = rkrsslc_pidm
    WHERE
        1=1
        AND rkrsslc_finaid_year = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc) -- Current year in the SLC table
        AND rkrsslc_file_type = 'ATFEE'
        AND s1.sorlcur_cact_code = 'ACTIVE'
        AND s1.sorlcur_lmod_code = 'LEARNER'
        AND s1.sorlcur_current_cde = 'Y'
        AND s1.sorlcur_coll_code != 'AS'
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
                AND s2.sorlcur_term_code <= stvterm_code
            )
        -- End term of curricula record is greater than or equal to the first term of the current finaid year
        AND (SELECT stvterm_code FROM stvterm WHERE s1.sorlcur_end_date BETWEEN stvterm_start_date AND stvterm_end_date)
		    >= (SELECT stvterm_code FROM stvterm WHERE stvterm_fa_proc_yr = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc) AND stvterm_fa_term = 1)
        --AND rkrsslc_pidm = '1306793'
) a
group by
	pidm,
    program,
    key_seqno,
    finaid_year,
    term_code,
    sslc_seq_no,
    ATFEE_STATUS,
    a.rkrsslc_slc_course_code
;

SELECT spriden_pidm FROM spriden WHERE spriden_id = '15065873';

SELECT * FROM rkrsslc WHERE rkrsslc_pidm = '1306793' AND rkrsslc_file_type = 'ATFEE';

SELECT * FROM skvssdt WHERE skvssdt_sdat_code_entity='ESC_SLC'
                and skvssdt_sdat_code_attr='COURSE_CODE' AND (skvssdt_data = 'PGCEQ/D' OR skvssdt_data_2 = 'PGCEQ/D' OR skvssdt_data_3 = 'PGCEQ/D' OR skvssdt_sdat_code_opt_2 = 'PGCEQ/D' OR skvssdt_sdat_code_opt_3 = 'PGCEQ/D');
                
                SELECT * FROM rkrsslc;