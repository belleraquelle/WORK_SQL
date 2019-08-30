SELECT
    spriden_id, sprcmnt.*
FROM
    sprcmnt
    JOIN spriden ON sprcmnt_pidm = spriden_pidm
WHERE
    1=1
    AND sprcmnt_cmtt_code = 'PWD'
    --AND sprcmnt_date >= '22-AUG-19'
    AND sprcmnt_user_id IS NOT NULL
    AND spriden_change_ind IS NULL