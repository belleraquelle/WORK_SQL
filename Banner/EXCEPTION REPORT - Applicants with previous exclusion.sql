/**
  Report to identify applicants who have been previously excluded. Need to check if it is okay to admit them
  based on the reason for their prior exclusion. Where an applicant is deemed to be permitted to come back,
  they can be added to the popsel 'PERMITTED_TO_RETURN' to exclude them from this report.
 */

SELECT
    f1.spriden_id AS "Banner ID",
    f1.spriden_last_name || ', ' || f1.spriden_first_name AS "Applicant Name",
    a1.saradap_pidm AS "PIDM",
    a1.saradap_term_code_entry AS "Entry Term",
    a1.saradap_apst_code AS "Application Status",
    a1.saradap_levl_code AS "Application Level",
    a1.saradap_program_1 AS "Application Programme",
    --a1.saradap_coll_code_1 AS "Application Faculty",
    --a1.saradap_degc_code_1 AS "Application Award",
    --a1.saradap_majr_code_1 AS "Application Major",
    b1.sarappd_apdc_code AS "Application Decision",
    c1.sfbetrm_term_code AS "Term Excluded",
    c1.sfbetrm_ests_code AS "Enrolment Status Code",
    d1.stvests_desc AS "Enrolment Status Description",
    c1.sfbetrm_rgre_code AS "Withdrawal Reason Code",
    e1.stvrgre_desc AS "Withdrawal Reason Description"
FROM
    saradap a1
    LEFT JOIN sarappd b1 ON a1.saradap_pidm = b1.sarappd_pidm
                                AND a1.saradap_term_code_entry = b1.sarappd_term_code_entry
                                AND a1.saradap_appl_no = b1.sarappd_appl_no
                                AND b1.sarappd_apdc_date = (
                                    SELECT MAX (b2.sarappd_apdc_date)
                                    FROM sarappd b2
                                    WHERE b1.sarappd_pidm = b2.sarappd_pidm
                                      AND b1.sarappd_term_code_entry = b2.sarappd_term_code_entry
                                      AND b1. sarappd_appl_no = b2.sarappd_appl_no
            )
    JOIN sfbetrm c1 ON a1.saradap_pidm = c1.sfbetrm_pidm
    JOIN stvests d1 ON c1.sfbetrm_ests_code = d1.stvests_code
    JOIN stvrgre e1 ON c1.sfbetrm_rgre_code = e1.stvrgre_code
    JOIN spriden f1 ON saradap_pidm = f1.spriden_pidm AND f1.spriden_change_ind IS NULL
WHERE
    -- Limit to future applications
    a1.saradap_term_code_entry > (SELECT stvterm_code FROM stvterm WHERE sysdate BETWEEN stvterm_start_date AND stvterm_end_date)
    -- Exclude withdrawn applications
    AND a1.saradap_apst_code != 'W'
    -- Exclude declined, rejected and withdrawn decisions
    AND b1.sarappd_apdc_code NOT IN ('CD', 'UD', 'W', 'R')
    -- Limit to records where student has a registration record indicating prior exclusion
    AND (
        (sfbetrm_ests_code = 'WD' AND sfbetrm_rgre_code LIKE 'X%')
        OR (sfbetrm_ests_code = 'XF')
    )
    -- Exclude excluded students permitted to return
    AND a1.saradap_pidm NOT IN (
        SELECT glbextr_key
        FROM glbextr
        WHERE glbextr_selection = 'PERMITTED_TO_RETURN'
    )
ORDER BY
    a1.saradap_pidm
;

