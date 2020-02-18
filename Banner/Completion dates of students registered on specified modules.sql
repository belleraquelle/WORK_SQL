/*

Will return student numbers, PIDMs and expected completion dates for students registered on specified modules.

*/

SELECT DISTINCT
    spriden_id,
    sfrstcr_pidm,
    --ssbsect_subj_code || ssbsect_crse_numb,
    --sfrstcr_term_code,
    --ssbsect_ptrm_end_date,
    t1.sorlcur_program,
    t1.sorlcur_seqno,
    t1.sorlcur_lmod_code,
    t1.sorlcur_end_date
FROM
    sfrstcr
    JOIN ssbsect ON sfrstcr_term_code = ssbsect_term_code AND sfrstcr_crn = ssbsect_crn
    JOIN sorlcur t1 on sfrstcr_pidm = sorlcur_pidm
    JOIN spriden on sfrstcr_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
    1=1
    AND ssbsect_subj_code || ssbsect_crse_numb IN (
        'ODP5002',
        'MWIF6015',
        'MWIF7014',
        'PARA6002',
        'PARA5003',
        'NURS6033',
        'NURS6041',
        'NURS7069',
        'NURS7075',
        'NURS7087',
        'HESC5010',
        'NURS7091',
        'NURS6045'
    )
    AND sfrstcr_rsts_code IN ('RE','RW')
    AND ssbsect_ptrm_end_date LIKE ('%MAY-20')
    AND t1.sorlcur_term_code = (SELECT MAX(t2.sorlcur_term_code) FROM sorlcur t2 WHERE t1.sorlcur_pidm = t2.sorlcur_pidm AND t1.sorlcur_key_seqno = t2.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER')
    AND t1.sorlcur_lmod_code = 'LEARNER'
    AND t1.sorlcur_cact_code = 'ACTIVE'
    AND t1.sorlcur_current_cde = 'Y'
    AND t1.sorlcur_term_code_end IS NULL
    AND t1.sorlcur_end_date BETWEEN '01-MAY-2020' AND '31-JUL-2020'
;