SELECT 
    sorlcur_term_code_admit AS "Admit Term", 
    sorlcur_program AS "Programme", 
    s.SPRIDEN_ID AS Student_ID, 
    s.SPRIDEN_LAST_NAME||', '|| s.SPRIDEN_FIRST_NAME AS Student, 
    a.SPRIDEN_ID AS Advisor_ID, 
    a.SPRIDEN_LAST_NAME ||', '|| a.SPRIDEN_FIRST_NAME AS Advisor, 
    SGRADVR_TERM_CODE_EFF AS Term, 
    SGRADVR_ADVR_CODE, 
    SGRADVR_PRIM_IND,
    sorlcur_end_date
FROM 
    sgradvr, 
    sorlcur, 
    spriden s, 
    spriden a
WHERE 
    1=1
    AND SGRADVR_PIDM = SORLCUR_PIDM
    AND SGRADVR_PIDM = s.SPRIDEN_PIDM
    and SGRADVR_ADVR_PIDM = a.SPRIDEN_PIDM
    and sorlcur_lmod_code = 'LEARNER'
    AND sorlcur.sorlcur_term_code_end IS NULL
    --and sorlcur.sorlcur_levl_code = 'UG'
    AND s.SPRIDEN_CHANGE_IND IS NULL
    AND sorlcur_end_date > sysdate
    AND a.SPRIDEN_id like 'P%'
    AND SGRADVR_ADVR_CODE = 'T001'
    ---OR SGRADVR_ADVR_CODE = 'R004'
    AND a.spriden_id = 'P0075759'
    ORDER BY 
        s.SPRIDEN_PIDM, 
        SGRADVR_ADVR_CODE
;