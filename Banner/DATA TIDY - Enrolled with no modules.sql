SELECT DISTINCT
    sfbetrm_pidm, spriden_id, sfbetrm_term_code, sfbetrm_ests_code, sfrensp_key_seqno, sfrensp_term_code, sfrensp_ests_code, sorlcur_key_seqno, sorlcur_program, sorlcur_camp_code
FROM
    sfbetrm
    JOIN sfrensp ON sfbetrm_pidm = sfrensp_pidm AND sfbetrm_term_code = sfrensp_term_code
    JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sorlcur ON sfrensp_pidm = sorlcur_pidm AND sfrensp_key_seqno = sorlcur_key_seqno AND sorlcur_lmod_code = 'LEARNER'
WHERE
    1=1
    AND sfbetrm_term_code = '201909'
    AND sfbetrm_ests_code = 'EN'
    AND sfbetrm_pidm NOT IN (
        SELECT DISTINCT sfrstcr_pidm
        FROM sfrstcr JOIN ssbsect ON sfrstcr_term_code = ssbsect_term_code AND sfrstcr_crn = ssbsect_crn
        WHERE 
            1=1
            AND (
                (ssbsect_term_code = '201901' 
                    AND ssbsect_ptrm_code IN ('S21', 'T21', 'T31', 'E10', 'E12', 'F10', 'G10', 'I8'))
                OR
                (ssbsect_term_code = '201906' 
                    AND ssbsect_ptrm_code IN ('S31', 'T41', 'J5','J7', 'K5'))
                OR
                (ssbsect_term_code = '201909')
                )
            AND sfrstcr_rsts_code IN ('RE','RW')
            )
    AND sorlcur_camp_code IN ('OBO','OBS','DL')
    AND sorlcur_levl_code != 'RD'
    AND sorlcur_term_code_admit = '201909'
    --AND spriden_id = '15050603'
ORDER BY
    sorlcur_program
;