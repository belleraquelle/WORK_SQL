SELECT
    --LPAD(goksels.f_name_bio_value(rkrsslc_pidm,'ID'),8,0) AS id,
    slc.rkrsslc_pidm, 
    slc.rkrsslc_finaid_year, 
    slc.rkrsslc_seq_no,
    NVL(a."INITIAL_ATFEE_STATUS",'C') AS atfee_status  
    --a."PIDM",a."FINAID_YEAR",a."PROGRAM",a."KEY_SEQNO",a."TERM_CODE", a."STATUS", a."LAST_TERM_CODE", a."LAST_STATUS",a."ATFEE_STATUS", a."SSLC_SEQ_NO", a.rkrsslc_slc_course_code, a.atts_code, a.rkrsslc_course_year
FROM rkrsslc slc LEFT JOIN (
    SELECT
        r1.rkrsslc_pidm pidm,
     	--rkrsslc_acad_year,
    	r1.rkrsslc_finaid_year finaid_year,
     	r1.rkrsslc_seq_no sslc_seq_no,
        --s1.sorlcur_program program,
     	--rkrsslc_course_tuition_fee,
     	--rkrsslc_slc_course_code,
     	--rkrsslc_course_year,
     	--s1.sorlcur_term_code_admit,
        --s1.sorlcur_key_seqno key_seqno,
        --atts.atts_code,
        --last_ests.last_status,
        --last_ests.last_term_code,
        --current_ests.status,
        --current_ests.term_code,
        (CASE
            WHEN
                last_ests.last_status = 'WITHDRAWN'
                THEN 'X'
            WHEN
                current_ests.status = 'SUSPENDED'
                THEN 'S'
            WHEN
                r1.rkrsslc_course_tuition_fee != accd.amount
                THEN 'F'
            WHEN
                r1.rkrsslc_course_year = 0
                AND current_ests.status = 'ENROLLED'
                AND atts.atts_code = 'S1'
                THEN 'A'
            WHEN
                r1.rkrsslc_course_year = 1
                AND current_ests.status = 'ENROLLED'
                AND (
                    atts.atts_code IN ('S1', 'X1')
                    OR
                    -- Include 1 year top-ups
                    (atts.atts_code = 'S3' and top_up.smrpaap_program IS NOT NULL)
                )
                THEN 'A'
            WHEN
                r1.rkrsslc_course_year = 2
                AND current_ests.status = 'ENROLLED'
                AND atts.atts_code IN ('S2', 'X2', 'X2A', 'SW')
                THEN 'A'
            WHEN
                r1.rkrsslc_course_year = 3
                AND s1.sorlcur_term_code_admit < '202009'
                AND current_ests.status = 'ENROLLED'
                AND atts.atts_code IN ('S2', 'X2')
                AND apsp.eot IN ('P1','P2','T1','G1')
                THEN 'A' -- Check for valid Year 3 records (pre-framework)
            WHEN
                r1.rkrsslc_course_year = 3
                AND s1.sorlcur_term_code_admit < '202009'
                AND current_ests.status = 'ENROLLED'
                AND atts.atts_code IN ('SW', 'S3')
                -- Exclude top-up courses
                AND top_up.smrpaap_program IS NULL
                THEN 'A' -- Check for valid Year 3 records (SW and S3 pre-framework)
            WHEN
                r1.rkrsslc_course_year = 3
                AND s1.sorlcur_term_code_admit >= '202009'
                AND current_ests.status = 'ENROLLED'
                AND atts.atts_code IN ('SW', 'S3')
                -- Exclude top-up courses
                AND top_up.smrpaap_program IS NULL
                THEN 'A' -- Check for valid Year 3 records (post-framework)
            WHEN
                r1.rkrsslc_course_year = 4
                AND s1.sorlcur_term_code_admit < '202009'
                AND current_ests.status = 'ENROLLED'
                AND atts.atts_code = 'X2'
                AND apsp.eot IN ('P1','P2','T1','G1')
                THEN 'A' -- Check for valid Year 4 records (pre-framework)
            WHEN
                r1.rkrsslc_course_year = 4
                AND s1.sorlcur_term_code_admit < '202009'
                AND current_ests.status = 'ENROLLED'
                AND atts.atts_code = 'XM'
                THEN 'A' -- Check for valid Year 4 records (XM pre-framework)
            WHEN
                r1.rkrsslc_course_year = 4
                AND s1.sorlcur_term_code_admit >= '202009'
                AND current_ests.status = 'ENROLLED'
                AND atts.atts_code IN ('X3A','XM')
                AND atts.term_code_eff >= '202106'
                THEN 'A' -- Check for valid Year 4 records (post-framework)'
            WHEN
                r1.rkrsslc_course_year = 5
                AND s1.sorlcur_term_code_admit < '202009'
                AND current_ests.status = 'ENROLLED'
                AND atts.atts_code = 'XM'
                AND apsp.eot IN ('P1','P2','T1','G1')
                THEN 'A' -- Check for valid Year 5 records (pre-framework)
            WHEN
                r1.rkrsslc_course_year = 5
                AND s1.sorlcur_term_code_admit >= '202009'
                AND current_ests.status = 'ENROLLED'
                AND atts.atts_code = 'XM'
                THEN 'A' -- Check for valid Year 5 records (post-framework)
            ELSE 'C'
        END
        ) INITIAL_ATFEE_STATUS
    FROM rkrsslc r1
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
    ) accd ON accd.pidm = r1.rkrsslc_pidm
    
    JOIN (
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
        r1.rkrsslc_slc_course_code = skvssdt_sdat_code_opt_1
    
    JOIN sorlcur s1 ON r1.rkrsslc_pidm = s1.sorlcur_pidm AND cm.course_code = s1.sorlcur_program
    
    -- Grab the latest term and its associated enrolment status from the current finaid_year
    LEFT JOIN (
        SELECT
           sfb.sfrensp_pidm last_pidm,
           sfb.sfrensp_term_code last_term_code,
           sfb.sfrensp_key_seqno last_study_path,
           (CASE
                WHEN sfb.sfrensp_ESTS_CODE IN ('AT', 'UT') THEN 'SUSPENDED'
                WHEN sfb.sfrensp_ESTS_CODE IN ('NS', 'WD', 'XF') THEN 'WITHDRAWN'
                WHEN sfb.sfrensp_ESTS_CODE IN ('EN') THEN 'ENROLLED'
            END) last_status
        FROM sfrensp sfb
    ) last_ests on
        last_ests.last_pidm = r1.rkrsslc_pidm
        AND last_ests.last_study_path = s1.sorlcur_key_seqno
        and last_ests.last_term_code = (
            SELECT MAX(sfrensp_term_code)
            FROM sfrensp
            WHERE 
                last_ests.last_pidm = sfrensp_pidm 
                AND last_ests.last_study_path = sfrensp_key_seqno
                and sfrensp_term_code IN (
                    SELECT stvterm_code
                    FROM stvterm
                    WHERE stvterm_fa_proc_yr = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc)
                )
        )
        
    -- Grab the current term and its associated enrolment status where it exists
    LEFT JOIN (
        SELECT
           sfb.sfrensp_pidm pidm,
           sfb.sfrensp_term_code term_code,
           sfb.sfrensp_key_seqno study_path,
           (CASE
                WHEN sfb.sfrensp_ESTS_CODE IN ('AT', 'UT') THEN 'SUSPENDED'
                WHEN sfb.sfrensp_ESTS_CODE IN ('NS', 'WD', 'XF') THEN 'WITHDRAWN'
                WHEN sfb.sfrensp_ESTS_CODE IN ('EN') THEN 'ENROLLED'
            END) status
        FROM sfrensp sfb
    ) current_ests on
        current_ests.pidm = r1.rkrsslc_pidm
        AND current_ests.study_path = s1.sorlcur_key_seqno
        and current_ests.term_code = stvterm_code

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
        atts.pidm = r1.rkrsslc_pidm
        and s1.SORLCUR_KEY_SEQNO = atts.KEY_SEQNO
        
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
        AND apsp.PIDM = r1.rkrsslc_pidm
    
    -- Left join to programme table where programme is a one year top-up so top-up years can be correctly identified and handled in the case statement
    LEFT JOIN (
        SELECT smrpaap_program FROM (
            SELECT DISTINCT
                t1.smrpaap_program, 
                smralib_atts_code, 
                COUNT(DISTINCT smralib_atts_code) OVER (PARTITION BY t1.smrpaap_program) AS AREA_COUNT 
            FROM 
                smrpaap t1 
                JOIN smralib ON t1.smrpaap_area = smralib_area 
            WHERE 
                t1.smrpaap_term_code_eff = (
                    SELECT MAX(s2.smrpaap_term_code_eff) 
                    FROM smrpaap s2 
                    WHERE t1.smrpaap_program = s2.smrpaap_program) 
                    AND t1.smrpaap_program IN (SELECT smrpaap_program FROM smrpaap JOIN smralib ON smralib_area = smrpaap_area WHERE smralib_atts_code = 'S3')
            ) WHERE AREA_COUNT = 1) top_up ON 
                s1.sorlcur_program = top_up.smrpaap_program
                
    WHERE
        1=1
        AND r1.rkrsslc_finaid_year = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc) -- Current year in the SLC table
        AND r1.rkrsslc_file_type = 'ATFEE'
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
                    AND s2.sorlcur_term_code <= stvterm_code
                )
        -- End term of curricula record is greater than or equal to the first term of the current finaid year
        AND (SELECT stvterm_code FROM stvterm WHERE s1.sorlcur_end_date BETWEEN stvterm_start_date AND stvterm_end_date)
           >= (SELECT stvterm_code FROM stvterm WHERE stvterm_fa_proc_yr = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc) AND stvterm_fa_term = 1)
) a ON slc.rkrsslc_pidm = a.pidm AND slc.rkrsslc_finaid_year = a.finaid_year AND slc.rkrsslc_seq_no = a.sslc_seq_no
WHERE  
    slc.rkrsslc_finaid_year = (SELECT max(rkrsslc_finaid_year) FROM rkrsslc) -- Current year in the SLC table
    AND slc.rkrsslc_file_type = 'ATFEE'
    --AND slc.rkrsslc_pidm = '1332280'
;