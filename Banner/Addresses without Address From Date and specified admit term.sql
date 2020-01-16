SELECT spriden_id, spraddr_atyp_code 
FROM spraddr
    JOIN spriden ON spraddr_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sorlcur ON sorlcur_pidm = spraddr_pidm AND sorlcur_lmod_code = 'LEARNER' AND sorlcur_term_code_admit = '202001'
WHERE spraddr_from_date IS NULL;