SELECT DISTINCT
    sgbstdn.sgbstdn_program_1, sgbstdn_pidm, sftregs.*
FROM
    sftregs
    JOIN sgbstdn ON sftregs_pidm = sgbstdn_pidm
WHERE
    sgbstdn_program_1 = 'BSCH-REZ'
    AND sftregs_rsts_code = 'RW'
ORDER BY
    sgbstdn_pidm
;