select gkrpptr_parent, gkrpptr_child, gkrpptr_owner, gkrpptr_started, gkrpptr_finished
from gkrpptr
where 1=1 
and gkrpptr_started is not null and gkrpptr_finished IS null;

SELECT * FROM missing_end_dates;