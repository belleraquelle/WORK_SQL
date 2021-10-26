SELECT * FROM obu_datatyding_new_19OCT21;
SELECT * FROM obu_datatyding_new_25OCT21 ORDER BY PIDM;

--DELETE FROM sprhold WHERE sprhold_pidm IN (SELECT pidm from obu_datatyding_new_19OCT21) AND sprhold_hldd_code = 'RX';
--UPDATE sgrstsp SET sgrstsp_stsp_code = 'IS' WHERE sgrstsp_term_code_eff = :term_code AND sgrstsp_pidm || sgrstsp_key_seqno IN (SELECT PIDM || Study_Path
--UPDATE sgbstdn SET sgbstdn_stst_code = 'IS' WHERE sgbstdn_term_code_eff = :term_code AND sgbstdn_pidm IN (SELECT PIDM
--UPDATE sfrensp SET sfrensp_ests_code = 'NS' WHERE sfrensp_term_code = :term_code AND sfrensp_pidm || sfrensp_key_seqno IN (SELECT PIDM || Study_Path
--UPDATE sfbetrm SET sfbetrm_ests_code = 'NS' WHERE sfbetrm_term_code = :term_code AND sfbetrm_pidm IN (SELECT PIDM
--UPDATE sfbetrm SET sfbetrm_ar_ind = 'N' WHERE sfbetrm_term_code = '202206' AND sfbetrm_pidm IN (SELECT spriden_pidm
--INSERT INTO sfrensp(sfrensp_term_code, sfrensp_pidm, sfrensp_key_seqno, sfrensp_ests_code, sfrensp_ests_date, sfrensp_add_date, sfrensp_activity_date, sfrensp_user, sfrensp_data_origin)
--SELECT '202109', PIDM, "Study_Path", 'NS', '21-OCT-21', '21-OCT-21', sysdate, 'BANSECR_SCLARKE', 'DataTidy' FROM (
--CREATE TABLE obu_datatyding_new_25OCT21 AS (


/*
*
* New Student Data Tidy Check
* 
*  1. Have the RX holds been cleared?
*  2. Is the student status IS?
*  3. Is the study path status IS?
*  4. Does end date = start date?
*  5. Is the first term SFBETRM status NS?
*  6. Are subsequent SFBETRM statuses null? 
*  7. Is the first term SFRENSP status NS?
*  8. Are subsequent SFRENSP statuses null? 
*  9. Does module registrations return null? 
*
*/

SELECT * 
FROM (
SELECT 
	spriden_id AS "Student_Number",
    spriden_pidm AS "PIDM",
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    CASE WHEN sprhold_hldd_code = 'RX' THEN 'Y' END AS "Current_RX_Hold",
    b1.sgbstdn_stst_code AS "Current_Student_Status",
    m1.sgrstsp_key_seqno AS Study_Path,
    m1.sgrstsp_stsp_code AS "Current_Study_Path_Status",
    a1.sorlcur_camp_code AS "Campus",
    a1.sorlcur_program AS "Programme_Code",
    CASE WHEN to_char(a1.sorlcur_start_date,'DD-MON-YYYY') = to_char(a1.sorlcur_end_date, 'DD-MON-YYYY') THEN 'Y' END AS "End_date_equals_start_date",
    (SELECT sfbetrm_ests_code FROM sfbetrm WHERE spriden_pidm = sfbetrm_pidm AND sfbetrm_term_code = '202109') AS "SFEBTRM_202109",
    (SELECT sfbetrm_ests_code FROM sfbetrm WHERE spriden_pidm = sfbetrm_pidm AND sfbetrm_term_code = '202201') AS "SFEBTRM_202201",
    (SELECT sfbetrm_ests_code FROM sfbetrm WHERE spriden_pidm = sfbetrm_pidm AND sfbetrm_term_code = '202206') AS "SFEBTRM_202206",
    (SELECT sfrensp_ests_code FROM sfrensp WHERE spriden_pidm = sfrensp_pidm AND sfrensp_term_code = '202109') AS "SFRENSP_202109",
    (SELECT sfrensp_ests_code FROM sfrensp WHERE spriden_pidm = sfrensp_pidm AND sfrensp_term_code = '202201') AS "SFRENSP_202201",
    (SELECT sfrensp_ests_code FROM sfrensp WHERE spriden_pidm = sfrensp_pidm AND sfrensp_term_code = '202206') AS "SFRENSP_202206",
    CASE WHEN EXISTS (SELECT 1 FROM sfrstcr WHERE spriden_pidm = sfrstcr_pidm AND sfrstcr_term_code >= '202109') THEN 'Y' END AS "Module_Registrations?"
FROM 
	sorlcur a1
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sgbstdn b1 ON a1.sorlcur_pidm = b1.sgbstdn_pidm
    JOIN smrprle ON a1.sorlcur_program = smrprle_program
    LEFT JOIN sprhold ON a1.sorlcur_pidm = sprhold_pidm AND sprhold_hldd_code = 'RX' AND sysdate BETWEEN sprhold_from_date AND sprhold_to_date
    LEFT JOIN skricas ON a1.sorlcur_pidm = skricas_pidm AND a1.sorlcur_seqno = skricas_lcur_seqno
    LEFT JOIN szrenrl ON a1.sorlcur_pidm = szrenrl_pidm AND szrenrl_term_code = '202109'
    LEFT JOIN sgrstsp m1 ON sgrstsp_pidm = a1.sorlcur_pidm AND sgrstsp_key_seqno = a1.sorlcur_key_seqno
WHERE
	1=1
	
	-- SORLCUR requirements  
	AND a1.sorlcur_lmod_code = 'LEARNER'
	AND a1.sorlcur_cact_code = 'ACTIVE'
	AND a1.sorlcur_current_cde = 'Y'
	AND a1.sorlcur_term_code = ( 
		
		SELECT MAX(a2.sorlcur_term_code)
		FROM sorlcur a2
		WHERE
			1=1
			AND a1.sorlcur_pidm = a2.sorlcur_pidm
			AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno
			AND a2.sorlcur_lmod_code = 'LEARNER'
			AND a2.sorlcur_cact_code = 'ACTIVE'
			AND a2.sorlcur_current_cde = 'Y'
	
		)
		
	-- Exclude VSMS programmes
	AND a1.sorlcur_program NOT LIKE ('%-V')
		
	-- Limit to specified admit term	
	AND a1.sorlcur_term_code_admit = '202109'

    -- Limit to students in the snapshot table of students to be tidied
	AND spriden_pidm IN (
        SELECT DISTINCT PIDM FROM obu_datatyding_new_25OCT21
        )
    
    -- Pick out latest learner record
    --AND b1.sgbstdn_term_code_eff = (SELECT MAX(b2.sgbstdn_term_code_eff) FROM sgbstdn b2 WHERE b1.sgbstdn_pidm = b2.sgbstdn_pidm)
    AND b1.sgbstdn_term_code_eff = '202109'
    
    -- Pick out latest study path record
    --AND m1.sgrstsp_term_code_eff = (SELECT MAX(n1.sgrstsp_term_code_eff) FROM sgrstsp n1 WHERE m1.sgrstsp_pidm = n1.sgrstsp_pidm AND m1.sgrstsp_key_seqno = n1.sgrstsp_key_seqno)
    AND m1.sgrstsp_term_code_eff = '202109'
    
    --AND spriden_id = '19136721'
    
    -- Limit to students without an overall enrolment status
    --AND szrenrl_overall_enrol_status IS NULL
    
    -- Limit to entries with an SGRSTSP / SGBSTDN status of AS/IS
    --AND m1.sgrstsp_stsp_code = 'IS' 
    --AND b1.sgbstdn_stst_code = 'IS'
)
--WHERE SFRENSP_202109 IN ('NS','WD')
--WHERE SFEBTRM_202109 IN ('NS', 'WD')
--);
ORDER BY
    "Campus",
    "Programme_Code", 
    "Student_Name"    

;