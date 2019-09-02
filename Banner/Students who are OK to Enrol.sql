SELECT
    sgbstdn_term_code_admit,
    spriden_id, spriden_last_name || ', ' || spriden_first_name AS "StudentName", 
    sgbstdn_program_1,  
    a.gorsdav_value.accessVARCHAR2() as "Admit"
FROM
    sgbstdn
    JOIN spriden ON sgbstdn_pidm = spriden_pidm AND spriden_change_ind IS NULL
    LEFT JOIN gorsdav a ON a.gorsdav_table_name = 'SGBSTDN'
        AND a.gorsdav_attr_name = 'OVERALL_ENROL_STATUS'
        AND a.gorsdav_PK_PARENTTAB=sgbstdn_PIDM||CHR(1)||sgbstdn_TERM_CODE_EFF
WHERE
    1=1
    AND sgbstdn_STST_CODE = 'AS'
    AND a.gorsdav_VALUE.accessVARCHAR2() = 'OK'
ORDER BY
      sgbstdn_program_1,
      spriden_last_name || ', ' || spriden_first_name