select
    spriden_id as "ID",
    cur1.sorlcur_term_code as "Old_Curriculum_Record_Term",
    cur1.sorlcur_program as "Old_Curriculum_Record_Prog",
    sorlfos_csts_code as "Old_Curriculum_Record_Status",
    cur1.sorlcur_cact_code as "Old_Curriculum_Record_Activity",
    cur1.sorlcur_priority_no as "Old_Curriculum_Record_Priority",
    cur2.sorlcur_term_code as "New_Curriculum_Record_Term",
    cur2.sorlcur_program as "New_Curriculum_Record_Prog",
    cur2.sorlcur_priority_no as "New_Curriculum_Record_Priority"
from
    sorlcur cur1
    join sorlcur cur2 on cur1.sorlcur_pidm = cur2.sorlcur_pidm
    join spriden on cur1.sorlcur_pidm = spriden_pidm
    join sorlfos on sorlfos_pidm = cur1.sorlcur_pidm and cur1.sorlcur_seqno = sorlfos_lcur_seqno
where
    cur1.sorlcur_lmod_code = 'LEARNER'
    and cur2.sorlcur_lmod_code = 'LEARNER'
    and cur1.sorlcur_end_date < sysdate
    and cur1.sorlcur_priority_no not like '99%' -- This takes out the migrated 999 records that we might want to tidy later
    and cur2.sorlcur_term_code_admit = '201909'
    and cur1.sorlcur_term_code_end is null
    and cur1.sorlcur_cact_code != 'INACTIVE'
    and cur2.sorlcur_term_code_end is null
    and cur1.sorlcur_current_cde = 'Y'
    and cur2.sorlcur_current_cde = 'Y'
    and spriden_change_ind is null
order by
      ID
