SELECT * FROM tbrappl WHERE tbrappl_pidm = 1244843;

UPDATE tbrappl
SET tbrappl_amount = 4625, tbrappl_reappl_ind = 'Y' 
WHERE tbrappl_pidm = 1244843 AND tbrappl_pay_tran_number = 12 AND tbrappl_chg_tran_number = 11;

SELECT * FROM gjbprun WHERE gjbprun_one_up_no = -1;

DELETE FROM gjbprun WHERE gjbprun_one_up_no = -1;
