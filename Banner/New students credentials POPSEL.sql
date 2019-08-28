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

-- EXCLUDE STUDENTS WHO HAVE WITHDRAWN / DECLINED

    AND t1.sgrstsp_pidm NOT IN (
        SELECT DISTINCT spriden_pidm
        from  SARADAP , spriden, goremal
        where 1=1
        and spriden_pidm = SARADAP_pidm and  spriden_change_ind is null and spriden_pidm = goremal_pidm
        and exists ( select 1 from SARAPPD a , SARAPPD b
        where  a.SARAPPD_APPL_NO = SARADAP_APPL_NO  and a.SARAPPD_pidm = SARADAP_pidm and a.SARAPPD_APDC_CODE IN ('UT','UF')
        and  a.SARAPPD_TERM_CODE_ENTRY = SARADAP_TERM_CODE_ENTRY
        and b.SARAPPD_APPL_NO = SARADAP_APPL_NO  and b.SARAPPD_pidm = SARADAP_pidm and b.SARAPPD_APDC_CODE in ('W','D', 'UD')
        and b.SARAPPD_TERM_CODE_ENTRY = SARADAP_TERM_CODE_ENTRY
        and b.SARAPPD_SEQ_NO > a.SARAPPD_SEQ_NO
        and trunc(b.SARAPPD_APDC_DATE) =
        ( select trunc(max (a1.SARAPPD_APDC_DATE)) from SARAPPD a1
        where a1.SARAPPD_pidm = b.SARAPPD_pidm and b.SARAPPD_APPL_NO = a1.SARAPPD_APPL_NO)
        )
        and SARADAP_TERM_CODE_ENTRY = '201909'
        --and SARADAP_APST_CODE not in ('I','W')
        and exists (select 1 from sorlcur where sorlcur_pidm = saradap_pidm and SORLCUR_LMOD_CODE = 'LEARNER' )
            )

-- INCLUDE NEW STUDENTS
    AND t2.sorlcur_term_code_admit = '201909'
