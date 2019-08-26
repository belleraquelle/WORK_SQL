select distinct spriden_id, goremal_email_address, spriden_last_name , spriden_first_name, --a.SARAPPD_APDC_DATE,
SARADAP_PROGRAM_1,
SARADAP.*
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
and SARADAP_TERM_CODE_ENTRY = 201909
--and SARADAP_APST_CODE not in ('I','W')
and exists (select 1 from sorlcur where sorlcur_pidm = saradap_pidm and SORLCUR_LMOD_CODE = 'LEARNER' )
AND spriden_pidm IN (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = 'NEW_ENRL' AND glbextr_user_id = 'BANSECR_SCLARKE')
AND GOREMAL_EMAL_CODE = 'PERS' AND GOREMAL_PREFERRED_IND = 'Y'