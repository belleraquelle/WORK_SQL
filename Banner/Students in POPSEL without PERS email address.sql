SELECT
    spriden_id
FROM
    spriden
WHERE
    1=1
    AND sgbstdn_pidm NOT IN (
        SELECT goremal_pidm FROM goremal WHERE goremal_emal_code = 'PERS'
    )
    AND spriden_change_ind IS NULL
    AND spriden_pidm IN (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = 'NEW_ENRL' AND glbextr_user_id = 'BANSECR_SCLARKE')
