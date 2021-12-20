SELECT * FROM tbrappl WHERE tbrappl_pidm = 1244843;

UPDATE tbrappl
SET tbrappl_amount = 4625, tbrappl_reappl_ind = 'Y' 
WHERE tbrappl_pidm = 1244843 AND tbrappl_pay_tran_number = 12 AND tbrappl_chg_tran_number = 11;

SELECT * FROM gjbprun WHERE gjbprun_one_up_no = -1;

DELETE FROM gjbprun WHERE gjbprun_one_up_no = -1;


SELECT * FROM tbrappl WHERE tbrappl_feed_date > sysdate - 1;

SELECT * FROM GUROUTP WHERE guroutp_one_up_no = '107147';

SELECT * FROM saradap WHERE saradap_activity_date >= sysdate - 1 order by saradap_activity_date desc;