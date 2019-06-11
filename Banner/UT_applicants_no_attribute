SELECT DISTINCT
    SARADAP_PIDM,
    --SPRIDEN_ID,
    SARADAP_APPL_NO,
    SARADAP_TERM_CODE_ENTRY,
    SARAPPD_APDC_CODE,
    SARAPPD_SEQ_NO,
    SARAATT_TERM_CODE,
    SARAATT_ATTS_CODE
FROM
    SARADAP -- Application Table
    JOIN SPRIDEN ON (SARADAP_PIDM = SPRIDEN_PIDM)
    JOIN SARAPPD s1 ON (SARADAP_PIDM = SARAPPD_PIDM AND SARADAP_APPL_NO = SARAPPD_APPL_NO) -- Application Decision Table
    LEFT JOIN SARAATT ON (SARADAP_PIDM = SARAATT_PIDM AND SARADAP_APPL_NO = SARAATT_APPL_NO) -- Applicant Attribute Table
WHERE
     SARAPPD_APDC_CODE in ('UT', 'CF', 'CI')
     AND SARADAP_TERM_CODE_ENTRY = '201909'
     AND s1.sarappd_seq_no = (
         SELECT MAX(s2.sarappd_seq_no)
         FROM sarappd s2
         WHERE s2.sarappd_pidm = s1.sarappd_pidm and s2.sarappd_appl_no = s1.sarappd_appl_no)
ORDER BY
      SARADAP_PIDM
