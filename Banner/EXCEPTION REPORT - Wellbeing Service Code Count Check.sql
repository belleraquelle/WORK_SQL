SELECT * FROM (
    SELECT
        s1.serdtsr_pidm,
        spriden_id,
        (SELECT
            COUNT (s2.serdtsr_sser_code)
        FROM 
            serdtsr s2 
        WHERE 
            1=1
            AND s1.serdtsr_pidm = s2.serdtsr_pidm
            AND s2.serdtsr_sser_code LIKE :first_two_chars_of_service
            -- Exclude specific codes (on ES% for example)
            AND s2.serdtsr_sser_code NOT IN ('ESLR', 'ESPW', 'ESCR')
            AND s2.serdtsr_ssst_code = 'AG'
            AND (s2.serdtsr_end_date IS NULL OR s2.serdtsr_end_date > sysdate)
            AND s2.serdtsr_term_code_eff = (
                SELECT MAX(s3.serdtsr_term_code_eff) 
                FROM serdtsr s3 
                WHERE s2.serdtsr_pidm = s3.serdtsr_pidm
            )
        ) AS SERVICE_COUNT
    FROM
        serdtsr s1
        JOIN spriden ON s1.serdtsr_pidm = spriden_pidm AND spriden_change_ind IS NULL
        JOIN sorlcur a1 ON s1.serdtsr_pidm = a1.sorlcur_pidm
    WHERE
        1=1
        AND a1.sorlcur_lmod_code = 'LEARNER'
        AND a1.sorlcur_cact_code = 'ACTIVE'
        AND a1.sorlcur_current_cde = 'Y'
        AND a1.sorlcur_term_code = (
            SELECT MAX(a2.sorlcur_term_code)
            FROM sorlcur a2
            WHERE 
                1=1
                AND a1.sorlcur_pidm = a2.sorlcur_pidm
                AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno
                AND a2.sorlcur_lmod_code = 'LEARNER'
                AND a2.sorlcur_cact_code = 'ACTIVE'
                AND a2.sorlcur_current_cde = 'Y'
        )
        AND a1.sorlcur_end_date > sysdate
)
GROUP BY serdtsr_pidm, spriden_id, SERVICE_COUNT
HAVING SERVICE_COUNT > 1
;