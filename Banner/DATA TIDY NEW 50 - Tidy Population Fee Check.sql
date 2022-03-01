select
    (select spriden_id from spriden where spriden_pidm=t.tbraccd_pidm and spriden_change_ind is null) student
    ,tbraccd_pidm
    ,sum(TBRACCD_BALANCE) balance
from tbraccd t
where tbraccd_pidm in (
		select distinct sorlcur_pidm from obu_datatidying_new enrl
	)
group by tbraccd_pidm
having sum(TBRACCD_BALANCE)>0
;