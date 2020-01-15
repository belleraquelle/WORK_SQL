SELECT
    spriden_id, s1.sfbetrm_pidm, sgbstdn_program_1
FROM
    sfbetrm s1
    JOIN sfbetrm s2 ON s1.sfbetrm_pidm = s2.sfbetrm_pidm
    JOIN sgbstdn t1 ON s1.sfbetrm_pidm = t1.sgbstdn_pidm
    JOIN spriden ON s1.sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
    1=1
    AND s2.sfbetrm_ests_code IN ('UT','AT') AND s2.sfbetrm_term_code = '201909'
    AND s1.sfbetrm_ests_code = 'EN' AND s1.sfbetrm_term_code = '202001'
    AND t1.sgbstdn_term_code_eff = (SELECT MAX(t2.sgbstdn_term_code_eff) FROM sgbstdn t2 WHERE t1.sgbstdn_pidm = t2.sgbstdn_pidm)
ORDER BY
    sgbstdn_program_1
;