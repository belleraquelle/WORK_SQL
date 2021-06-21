
UPDATE  rkrsslc sslc
SET     rkrsslc_atfe_status      = 'F',
       rkrsslc_atfe_status_date = sysdate
WHERE   rkrsslc_file_type        = 'ATFEE'
AND     rkrsslc_finaid_year      = '2021' 
AND     rkrsslc_pidm             = :pidm
AND EXISTS (
select 1
from sfbetrm sfb
,stvterm stv
where 1=1
and RKRSSLC_FINAID_YEAR='2021'
and RKRSSLC_FILE_TYPE='ATFEE'
and rkrsslc_pidm=sfb.sfbetrm_pidm
and sfb.sfbetrm_term_code = stv.stvterm_code
and sfb.SFBETRM_ESTS_CODE='EN'
and stv.stvterm_fa_proc_yr='2021'
and RKRSSLC_COURSE_TUITION_FEE != (select  sum(tbraccd_amount)    
                                       from tbraccd
                                       where 1=1
                                       and TBRACCD_SRCE_CODE ='R'
                                       and tbraccd_pidm=rkrsslc_pidm
                                       and tbraccd_term_code in ( select stvterm_code
                                                    from stvterm 
                                                    where 1=1
                                                    and stvterm_fa_proc_yr=rkrsslc_finaid_year
                                                    )))