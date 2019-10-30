SELECT DISTINCT
    sobcurr_program,
    smrprle_program_desc,
    valstatus_1,
    sorcmjr_majr_code, 
    sorcmjr_desc
FROM
    sobcurr_add
    JOIN smrprle ON sobcurr_add.sobcurr_program = smrprle_program
    JOIN sorcmjr ON sorcmjr_curr_rule = sobcurr_curr_rule
WHERE 
    1=1
    AND ump_1 = 'Y'
    AND valstatus_1 IN ('CA','CL','FA')
ORDER BY
    sorcmjr_majr_code,
    sobcurr_program
;