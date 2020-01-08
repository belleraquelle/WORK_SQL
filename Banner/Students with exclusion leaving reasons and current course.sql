/*
Lists any student with an exclusion leaving reason recorded between the
dates specified.

Note that it returns the student's CURRENT course, so may not pull through
the course they were excluded from.
*/


SELECT
    spriden_id, spriden_last_name, spriden_first_name, sgbstdn_program_1, sfbetrm.*
FROM
    sfbetrm
    JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgbstdn a1 ON sfbetrm_pidm = sgbstdn_pidm
WHERE
    1=1
    AND sfbetrm_rgre_code LIKE 'X%'
    AND sfbetrm_ests_date BETWEEN '01-JAN-19' AND '06-JAN-20'
    AND a1.sgbstdn_term_code_eff = (
        SELECT MAX(a2.sgbstdn_term_code_eff)
        FROM sgbstdn a2
        WHERE a1.sgbstdn_pidm = a2.sgbstdn_pidm)
ORDER BY
    sgbstdn_program_1
;