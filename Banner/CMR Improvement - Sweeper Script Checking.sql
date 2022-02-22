SELECT COUNT(saradap_pidm||saradap_term_code_entry||saradap_appl_no) 
FROM saradap 
WHERE saradap_resd_code = '0' AND saradap_term_code_entry = '202109';



SELECT spriden_id, saradap.* 
FROM saradap JOIN spriden ON saradap_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE saradap_term_code_entry = '202109' AND saradap_resd_code = '0';

SELECT saradap_term_code_entry, saradap_appl_no, saradap_pidm, saradap_resd_code, saradap_activity_date 
FROM saradap 
WHERE saradap_pidm = '1355825';


SELECT * FROM saradap;