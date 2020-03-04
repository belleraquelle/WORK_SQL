SELECT DISTINCT
    subj_coord_1
FROM
    sobcurr_add
WHERE 
    ump_1 = 'Y'
    AND valstatus_1 IN ('CA', 'CL')
;