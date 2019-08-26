SELECT
    spriden_id, sorlcur_program, goremal_email_address
FROM
    spriden
    JOIN sorlcur ON spriden_pidm = sorlcur_pidm
    JOIN goremal ON spriden_pidm = goremal_pidm
    JOIN sgbstdn ON spriden_pidm = sgbstdn_pidm AND sorlcur_term_code = sgbstdn_term_code_eff
WHERE
    1=1
    AND spriden_change_ind IS NULL
    --AND spriden_pidm IN (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = 'NEW_ENRL' AND glbextr_user_id = 'BANSECR_SCLARKE')
    AND sorlcur_lmod_code = 'LEARNER'
    AND sorlcur_term_code_admit = '201909'
    AND goremal_preferred_ind = 'Y'
    AND goremal_emal_code = 'PERS'
    AND sorlcur_program IN (
        'MA-FPC',
        'MA-PA',
        'MARCD-ADA',
        'MMATH-AM',
        'MSC-MY',
        'MSC-NRS/NCT',
        'MSC-NRS/NMH',
        'MSC-NRS/NSA',
        'MSC-NRS/NSA',
        'MSC-OT',
        'MSC-PZ',
        'PFGCEP-PCE',
        'PGCEP-PCE',
        'PGCE/D',
        'PGCEQ',
        'PGCEQ/D',
        'FNDIP-FBE',
        'FNDIP-FBU',
        'FNDIP-FCO',
        'FNDIP-FEG',
        'FNDIP-FLL',
        'FNDIP-FHU',
        'FNDIP-IFA',
        'FNDIP-IFB',
        'FNDIP-LSF'
    )
ORDER BY
      sorlcur_program