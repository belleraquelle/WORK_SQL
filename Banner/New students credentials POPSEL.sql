/*
INSERT INTO GLBEXTR A (A.GLBEXTR_APPLICATION
, A.GLBEXTR_SELECTION
, A.GLBEXTR_CREATOR_ID
, A.GLBEXTR_USER_ID
, A.GLBEXTR_KEY
, A.GLBEXTR_ACTIVITY_DATE
, A.GLBEXTR_SYS_IND)
*/
SELECT DISTINCT 'STUDENT' c1 , 
'NEW_ENRL' c2 , 
'BANSECR_SCLARKE' c3 , 
'BANSECR_SCLARKE' c4 , 
sgrstsp_pidm c5 , 
sysdate c6 , 
'M' c7 
 FROM SGRSTSP t1 , SORLCUR t2 , SORLFOS t3 
 WHERE ((sgrstsp_pidm = sorlcur_pidm AND sgrstsp_key_seqno = sorlcur_key_seqno)
AND (sorlcur_pidm = sorlfos_pidm AND sorlcur_seqno = sorlfos_lcur_seqno))
 AND 1=1

-- IDENTIFY STUDENTS WITH ACTIVE STUDY PATHS
    AND t1.sgrstsp_term_code_eff = (
        SELECT MAX(a2.sgrstsp_term_code_eff)
        FROM sgrstsp a2
        WHERE t1.sgrstsp_pidm = a2.sgrstsp_pidm AND t1.sgrstsp_key_seqno = a2.sgrstsp_key_seqno AND t1.sgrstsp_stsp_code = 'AS'
    )
  
AND (t2.sorlcur_term_code != t2.sorlcur_term_code_end or t2.sorlcur_term_code_end is null)

-- ONLY INCLUDE PROPER SORLCUR RECORDS
    AND t3.SORLFOS_csts_code = 'INPROGRESS'

-- EXCLUDE STUDENTS WHO ARE ALREADY EN/AT/UT/WD FOR THE TERM
    AND t1.sgrstsp_pidm NOT IN (
        SELECT sfrensp_pidm FROM sfrensp WHERE sfrensp_term_code = '201909' AND sfrensp_ests_code in ('AT', 'EN', 'UT', 'WD')
    )

-- EXCLUDE STUDENTS WHO ARE HAVE ALREADY HAD THE CREDENTIALS SENT TO THEM

    AND t1.sgrstsp_pidm NOT IN (
        SELECT sgbstdn_pidm
        FROM sgbstdn_add
        WHERE sgbstdn_term_code_eff = '201909' AND acenrol_status_1 IS NOT NULL
    )

-- INCLUDE NEW STUDENTS
    AND t2.sorlcur_term_code_admit = '201909'
