SELECT DISTINCT
    --sgbstdn_term_code_admit,
    sorlcur_term_code_admit, 
    spriden_id, spriden_last_name || ', ' || spriden_first_name AS "StudentName",
    sgbstdn_program_1,
    sorlcur_program,
    sgbstdn_camp_code,
    sorlcur_styp_code,
    a.gorsdav_value.accessVARCHAR2() as "AcEnrol",
    b.gorsdav_value.accessVARCHAR2() as "FinEnrol",
    sfbetrm_ests_code,
    sarappd_apdc_date
FROM
    sgbstdn
    JOIN spriden ON sgbstdn_pidm = spriden_pidm AND spriden_change_ind IS NULL
    LEFT JOIN gorsdav a ON a.gorsdav_table_name = 'SGBSTDN'
        AND a.gorsdav_attr_name = 'ACENROL_STATUS'
        AND a.gorsdav_PK_PARENTTAB=sgbstdn_PIDM||CHR(1)||sgbstdn_TERM_CODE_EFF
    LEFT JOIN gorsdav b ON a.gorsdav_table_name = 'SGBSTDN'
        AND b.gorsdav_attr_name = 'FINENROL_STATUS'
        AND b.gorsdav_PK_PARENTTAB=sgbstdn_PIDM||CHR(1)||sgbstdn_TERM_CODE_EFF
    JOIN sorlcur ON sgbstdn_pidm = sorlcur_pidm
    JOIN sfbetrm ON sgbstdn_pidm = sfbetrm_pidm
    LEFT JOIN sarappd ON sgbstdn_pidm = sarappd_pidm
WHERE
    1=1
    AND sgbstdn_STST_CODE = 'AS'
    AND (a.gorsdav_VALUE.accessVARCHAR2() = 'OP'
        OR b.gorsdav_VALUE.accessVARCHAR2() = 'OP')
    AND sorlcur_term_code_admit = '201909'
    AND sfbetrm_term_code = '201909'
    AND sfbetrm_ests_code = 'EL'
    AND sorlcur_styp_code = 'F'
    AND sorlcur_current_cde = 'Y'
    AND spriden_change_ind IS NULL
    AND (sarappd_apdc_code = 'UF' OR sarappd_apdc_code IS NULL)
ORDER BY
      sarappd_apdc_date,
      sgbstdn_program_1,
      spriden_last_name || ', ' || spriden_first_name
;