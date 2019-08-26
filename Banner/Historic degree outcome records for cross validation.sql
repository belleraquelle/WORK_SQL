SELECT
    spriden_id,
    spriden_pidm,
    spriden_last_name,
    spriden_first_name,
    shrdgmr_program,
    shrdgmr_degc_code,
    shrdgih_honr_code,
    shrdgmr_degs_code,
    shrdgmr_grad_date AS "Award_Date",
    shbdipl_order_date,
    shrdcmt_comment
FROM
    shrdgmr
    JOIN shrdgih ON shrdgmr_pidm = shrdgih_pidm AND shrdgmr_seq_no = shrdgih_dgmr_seq_no
    JOIN spriden ON shrdgmr_pidm = spriden_pidm
    JOIN shbdipl ON shrdgmr_pidm = shbdipl_pidm AND shrdgmr_seq_no = shbdipl_dgmr_seq_no
    JOIN shrdcmt ON shbdipl_pidm = shrdcmt_pidm AND shbdipl_dgmr_seq_no = shrdcmt_dgmr_seq_no
WHERE
    1=1

    -- Only return AWarded awards
    AND shrdgmr_degs_code != 'SO'

    AND spriden_change_ind IS NULL

ORDER BY
      spriden_pidm