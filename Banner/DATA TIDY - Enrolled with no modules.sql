SELECT DISTINCT
    sfbetrm_pidm, spriden_id, sfbetrm_term_code, sfbetrm_ests_code, sfrensp_key_seqno, sfrensp_term_code, sfrensp_ests_code, sorlcur_key_seqno, sorlcur_program, sorlcur_camp_code
FROM
    sfbetrm
    JOIN sfrensp ON sfbetrm_pidm = sfrensp_pidm AND sfbetrm_term_code = sfrensp_term_code
    JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sorlcur ON sfrensp_pidm = sorlcur_pidm AND sfrensp_key_seqno = sorlcur_key_seqno AND sorlcur_lmod_code = 'LEARNER'
WHERE
    1=1
    AND sfbetrm_term_code = '202001'
    AND sfbetrm_ests_code = 'EN'
    AND sfbetrm_pidm NOT IN (
        SELECT DISTINCT sfrstcr_pidm
        FROM sfrstcr JOIN ssbsect ON sfrstcr_term_code = ssbsect_term_code AND sfrstcr_crn = ssbsect_crn
        WHERE 
            1=1
            AND (
                -- Modules ending in current semester
                (ssbsect_ptrm_end_date BETWEEN '01-JAN-20' AND '31-MAY-20') OR 
                
                -- Modules starting before or within current semester and extending past the end of the current semester
                (ssbsect_ptrm_start_date BETWEEN '01-SEP-19' AND '31-MAY-20' AND ssbsect_ptrm_end_date BETWEEN '01-JUN-20' AND '31-AUG-20')
                
                )
            AND sfrstcr_rsts_code IN ('RE','RW')
            )
    AND sorlcur_camp_code IN ('OBO','OBS','DL')
    AND sorlcur_levl_code != 'RD'
    --AND sorlcur_term_code_admit = '201909'
    --AND spriden_id = '15050603'
ORDER BY
    sorlcur_program
;