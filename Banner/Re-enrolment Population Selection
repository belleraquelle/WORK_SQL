/*

Re-enrolment Population Selection

*/

SELECT
    d1.spriden_id,
    a1.sgrstsp_pidm,
    a1.sgrstsp_key_seqno,
    a1.sgrstsp_term_code_eff,
    a1.sgrstsp_stsp_code,
    b1.sorlcur_key_seqno,
    b1.sorlcur_priority_no,
    b1.sorlcur_end_date,
    b1.sorlcur_term_code,
    b1.sorlcur_term_code_end,
    b1.sorlcur_curr_rule,
    c1.sorlfos_csts_code
FROM
    sgrstsp a1
    JOIN sorlcur b1 ON (a1.sgrstsp_pidm = b1.sorlcur_pidm AND a1.sgrstsp_key_seqno = b1.sorlcur_key_seqno)
    JOIN sorlfos c1 ON (b1.sorlcur_pidm = c1.sorlfos_pidm AND b1.sorlcur_seqno = c1.sorlfos_lcur_seqno)
    JOIN spriden d1 ON (a1.sgrstsp_pidm = d1.spriden_pidm)
WHERE
    1=1

-- CURRENT STUDENT NUMBER
    AND d1.spriden_change_ind IS NULL

-- IDENTIFY STUDENTS WITH ACTIVE STUDY PATHS
    AND a1.sgrstsp_term_code_eff = (
        SELECT MAX(a2.sgrstsp_term_code_eff)
        FROM sgrstsp a2
        WHERE a1.sgrstsp_pidm = a2.sgrstsp_pidm AND a1.sgrstsp_key_seqno = a2.sgrstsp_key_seqno
        AND a1.sgrstsp_stsp_code = 'AS'
    )


-- ONLY INCLUDE STUDY PATHS WITH A COMPLETION DATE BEYOND MASTERS DISSERTATION SUBMISSION DEADLINE
    AND b1.sorlcur_term_code = (
        SELECT MAX(b2.sorlcur_term_code)
        FROM sorlcur b2
        WHERE b1.sorlcur_pidm = b2.sorlcur_pidm AND b1.sorlcur_key_seqno = b2.sorlcur_key_seqno
        AND b1.sorlcur_lmod_code = 'LEARNER' AND sorlcur_end_date >= '01-OCT-2019'
    )

    AND b1.sorlcur_lmod_code = 'LEARNER' AND sorlcur_end_date >= '01-OCT-2019'

    AND (b1.sorlcur_term_code != b1.sorlcur_term_code_end or b1.sorlcur_term_code_end is null)

-- ONLY INCLUDE PROPER SORLCUR RECORDS
    AND c1.SORLFOS_csts_code = 'INPROGRESS'

-- EXCLUDE STUDENTS WHO ARE ALREADY EN/AT/UT/WD FOR THE TERM
    AND a1.sgrstsp_pidm NOT IN (
        SELECT sfrensp_pidm FROM sfrensp WHERE sfrensp_term_code = '201909' AND sfrensp_ests_code in ('AT', 'EN', 'UT', 'WD')
    )

-- EXCLUDE NEW STUDENTS
    AND b1.sorlcur_term_code_admit != '201909'

--AND d1.spriden_id = '18013434'

ORDER BY
    sorlcur_end_date ASC
