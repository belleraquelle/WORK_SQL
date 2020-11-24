SELECT
        sfbetrm_pidm,
        spriden_id,
        sorlcur_program,
        sfbetrm_term_code,
        SFBETRM_ACTIVITY_DATE,
        sfbetrm_ests_code,
        sfbetrm_rgre_code,
        sfrensp_key_seqno,
        sfrensp_activity_date,
        sfrensp_ests_code
FROM
        sfbetrm
        JOIN sfrensp ON sfbetrm_pidm = sfrensp_pidm AND sfbetrm_term_code = sfrensp_term_code
        JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
        JOIN sorlcur a1 ON sfrensp_pidm = a1.sorlcur_pidm AND sfrensp_key_seqno = a1.sorlcur_key_seqno
WHERE 

        1=1
        
        -- SORLCUR requirements  
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


        AND sfbetrm_term_code = '202009'
        AND (sfbetrm_ests_code = 'WD' OR sfrensp_ests_code = 'WD')
        AND sfbetrm_rgre_code = 'XF'
;

SELECT * FROM sfrensp;