select
spriden_id,
--shrtckn_subj_code||shrtckn_crse_numb modulecode,
--scbcrse.scbcrse_bill_hr_low as valuemod,
shrtckn.shrtckn_stsp_key_sequence,
SUM(shrtckg.shrtckg_credit_hours) credit
--scrattr_attr_code levelcode
--scbcrse.scbcrse_coll_code,
--SHRGRDE.SHRGRDE_PASSED_IND passfail,
--shrtckn_ptrm_end_date

from shrtckn,
shrtckg,
shrcmrk,
scrattr,
shrtckl,
shrgrde,
scbcrse,
spriden
where
    shrtckn.shrtckn_pidm IN (SELECT glbextr_key FROM glbextr WHERE glbextr_selection IN ('202001_PINK','202001_SILVER','202001_GOLD') AND glbextr_user_id = 'BANSECR_SCLARKE')
    and shrtckn.shrtckn_pidm NOT IN (SELECT shrapsp_pidm FROM shrapsp WHERE (shrapsp_prev_code = 'W1' OR shrapsp_astd_code_end_of_term = 'G3'))
and spriden_pidm = shrtckn_Pidm
and spriden_change_ind is null
and shrtckn.shrtckn_stsp_key_sequence IN (1, 2, 3, 4)

and shrtckl_term_code = shrtckn_term_code
and shrtckl_pidm = shrtckn_pidm
and shrtckn.shrtckn_seq_no = shrtckl.shrtckl_tckn_seq_no
and SHRTCKL.SHRTCKL_LEVL_CODE = SHRGRDE.SHRGRDE_LEVL_CODE
and SHRGRDE.SHRGRDE_ABBREV = SHRTCKG.SHRTCKG_GRDE_CODE_FINAL
and SHRGRDE.SHRGRDE_ATTEMPTED_IND = 'Y'
--and shrtckg.shrtckg_credit_hours > 0
and scrattr.scrattr_subj_Code = shrtckn.shrtckn_subj_code
and scrattr.scrattr_Crse_numb = shrtckn.shrtckn_crse_numb
and scbcrse.scbcrse_subj_Code = shrtckn.shrtckn_subj_code
and scbcrse.scbcrse_Crse_numb = shrtckn.shrtckn_crse_numb

and scrattr.scrattr_eff_term = '000000'
and scrattr.scrattr_attr_code in ('L3','L4','L5','L6')
--make sure student modules are for the study path of the student's programme
-- allow for null study path on SFVRHST as they don't all seem to have them (not sure if this is bad data)
and shrtckg.shrtckg_pidm = shrtckn.shrtckn_pidm
and shrtckg.shrtckg_pidm = shrcmrk.shrcmrk_pidm(+)
and shrtckg.shrtckg_term_code(+) = shrtckn.shrtckn_term_code

and shrtckn.shrtckn_term_code = shrcmrk.shrcmrk_term_code(+)

and shrtckn.shrtckn_crn = shrcmrk.shrcmrk_crn(+)
and shrtckg.shrtckg_tckn_seq_no = shrtckn.shrtckn_seq_no

and (shrcmrk_rectype_ind = 'F'
or shrcmrk_rectype_ind is null)

-- select final grade if multiple changes/moderations have occurred
and (shrtckg.shrtckg_seq_no = (select max(shrtckg_seq_no)
from shrtckg a
where  a.shrtckg_term_code = shrtckn.shrtckn_term_code
and a.shrtckg_tckn_seq_no = shrtckn.shrtckn_seq_no
and shrtckn.shrtckn_pidm = a.shrtckg_pidm))

-- get the right run of the module for credit value
and shrtckn.shrtckn_term_Code >= scbcrse.scbcrse_eff_term

and nvl((select min(c.scbcrse_eff_term)
from scbcrse c
where c.scbcrse_eff_term > scbcrse.scbcrse_eff_term
and c.scbcrse_subj_code = scbcrse.scbcrse_subj_code
and c.scbcrse_crse_numb =  scbcrse.scbcrse_crse_numb), '999999')  > shrtckn.shrtckn_term_code

-- if module is taken and passed twice only take the first pass
and (SHRGRDE.SHRGRDE_PASSED_IND = 'N'
or (SHRGRDE.SHRGRDE_PASSED_IND = 'Y'
and shrtckn.shrtckn_term_code = (select min(shrtckn2.shrtckn_term_code)
from shrtckn shrtckn2,
shrtckg shrtckg2,
shrtckl shrtckl2,
shrgrde shrgrde2
where shrtckn2.shrtckn_pidm = shrtckn.shrtckn_pidm
and shrtckn2.shrtckn_subj_code = shrtckn.shrtckn_subj_code
and shrtckn2.shrtckn_crse_numb = shrtckn.shrtckn_crse_numb
and shrtckl2.shrtckl_term_code = shrtckn2.shrtckn_term_code
and shrtckl2.shrtckl_pidm = shrtckn2.shrtckn_pidm
and shrtckn2.shrtckn_seq_no = shrtckl2.shrtckl_tckn_seq_no
and SHRTCKL2.SHRTCKL_LEVL_CODE = SHRGRDE2.SHRGRDE_LEVL_CODE
and SHRGRDE2.SHRGRDE_ABBREV = SHRTCKG2.SHRTCKG_GRDE_CODE_FINAL
and SHRGRDE2.SHRGRDE_PASSED_IND = 'Y'
--and shrtckg2.shrtckg_credit_hours > 0
and shrtckn2.shrtckn_stsp_key_sequence = shrtckn.shrtckn_stsp_key_sequence

and shrtckg2.shrtckg_pidm = shrtckn2.shrtckn_pidm
and shrtckg2.shrtckg_term_code(+) = shrtckn2.shrtckn_term_code

and shrtckg2.shrtckg_tckn_seq_no = shrtckn2.shrtckn_seq_no
-- select final grade if multiple changes/moderations have occurred
and (shrtckg2.shrtckg_seq_no = (select max(shrtckg_seq_no)
from shrtckg a
where  a.shrtckg_term_code = shrtckn2.shrtckn_term_code
and a.shrtckg_tckn_seq_no = shrtckn2.shrtckn_seq_no
and shrtckn.shrtckn_pidm = a.shrtckg_pidm))
)))
AND SHRGRDE.SHRGRDE_CODE IN ('F','FAIL','XF')
AND scrattr_attr_code IN ('L5','L6')

GROUP BY

spriden_id,
shrtckn.shrtckn_stsp_key_sequence,
scrattr_attr_code

HAVING SUM(shrtckg.shrtckg_credit_hours) >= 105
;