/*
This was courtesy of Stephen. It isn't working any more because of the change to the resit
logic. Can now just return failing modules that don't have a NOT ATTEMPTED comment against them.

shrmrks_comments IS NULL OR shrmrks_comments != 'Not Attempted'
*/


select scbcrse_subj_code||scbcrse_crse_numb as module_code, scbcrse_title,
case when shrsmrk_comments in ('Capped Resit', 'Uncapped Resit') then shrscom_description
else shrgcom_description end as assessment,
case when shrsmrk_comments in ('Capped Resit', 'Uncapped Resit') then shrsmrk_comments
else shrmrks_comments end as comments
from spriden
inner join sfrstcr on spriden_pidm = sfrstcr_pidm
inner join ssbsect on sfrstcr_crn = ssbsect_crn and sfrstcr_term_code = ssbsect_term_code
inner join scbcrse on ssbsect_subj_code = scbcrse_subj_code and ssbsect_crse_numb = scbcrse_crse_numb
inner join shrmrks on sfrstcr_crn = shrmrks_crn and sfrstcr_pidm = shrmrks_pidm
inner join shrgcom on shrmrks_gcom_id = shrgcom_id
left join shrsmrk on shrmrks_gcom_id = shrsmrk_gcom_id and sfrstcr_pidm = shrsmrk_pidm
left join shrscom on shrsmrk_scom_id = shrscom_id
where spriden_pidm = :pidm 
and sfrstcr_term_code in ('201810', '201718')
and (shrmrks_comments in ('Capped Resit', 'Uncapped Resit')
     or shrsmrk_comments in ('Capped Resit', 'Uncapped Resit'))