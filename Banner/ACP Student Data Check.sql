/*
 * This query pulls out current ACP student for checking and verification 
 */

WITH Modules AS
(
  SELECT sfrstcr_pidm
  ,max(seq) AS Cnt_modules
  
  ,MAX(DECODE(seq, 1, module_code)) "Module_1"   
  ,MAX(DECODE(seq, 1, module_term)) "Module_Term_1"
  ,MAX(DECODE(seq, 1, module_campus)) "Module_Campus_1"
  
  ,MAX(DECODE(seq, 2, module_code)) "Module_2"   
  ,MAX(DECODE(seq, 2, module_term)) "Module_Term_2"
  ,MAX(DECODE(seq, 2, module_campus)) "Module_Campus_2"
  
  ,MAX(DECODE(seq, 3, module_code)) "Module_3"   
  ,MAX(DECODE(seq, 3, module_term)) "Module_Term_3"
  ,MAX(DECODE(seq, 3, module_campus)) "Module_Campus_3"
  
  ,MAX(DECODE(seq, 4, module_code)) "Module_4"   
  ,MAX(DECODE(seq, 4, module_term)) "Module_Term_4"
  ,MAX(DECODE(seq, 4, module_campus)) "Module_Campus_4"
   
  ,MAX(DECODE(seq, 5, module_code)) "Module_5"   
  ,MAX(DECODE(seq, 5, module_term)) "Module_Term_5"
  ,MAX(DECODE(seq, 5, module_campus)) "Module_Campus_5"

  ,MAX(DECODE(seq, 6, module_code)) "Module_6"   
  ,MAX(DECODE(seq, 6, module_term)) "Module_Term_6"
  ,MAX(DECODE(seq, 6, module_campus)) "Module_Campus_6"
  
  ,MAX(DECODE(seq, 7, module_code)) "Module_7"   
  ,MAX(DECODE(seq, 7, module_term)) "Module_Term_7"
  ,MAX(DECODE(seq, 7, module_campus)) "Module_Campus_7"
  
  ,MAX(DECODE(seq, 8, module_code)) "Module_8"   
  ,MAX(DECODE(seq, 8, module_term)) "Module_Term_8"
  ,MAX(DECODE(seq, 8, module_campus)) "Module_Campus_8"
  
  ,MAX(DECODE(seq, 9, module_code)) "Module_9"   
  ,MAX(DECODE(seq, 9, module_term)) "Module_Term_9"
  ,MAX(DECODE(seq, 9, module_campus)) "Module_Campus_9"
  
  ,MAX(DECODE(seq, 10, module_code)) "Module_10"   
  ,MAX(DECODE(seq, 10, module_term)) "Module_Term_10"
  ,MAX(DECODE(seq, 10, module_campus)) "Module_Campus_10"
  
  FROM
  ( 
      SELECT 
      sfrstcr_pidm,
      sfrstcr_term_code AS module_term, 
      sfrstcr_crn,
      ssbsect_subj_code || ssbsect_crse_numb AS module_code,
      ssbsect_camp_code AS module_campus,
      row_number() OVER (PARTITION BY sfrstcr_pidm ORDER BY sfrstcr_term_code, sfrstcr_crn) seq

      FROM 
      	sfrstcr
      	JOIN ssbsect ON sfrstcr_term_code = ssbsect_term_code AND sfrstcr_crn = ssbsect_crn
      
      WHERE 
      	sfrstcr_term_code >= :current_term_code
      	AND ssbsect_ptrm_end_date < sysdate +300
      	AND ssbsect_subj_code != 'FEE'
      	AND sfrstcr_rsts_code IN ('RE','RW','RC','EN')
     
      ORDER BY sfrstcr_pidm, sfrstcr_term_code, sfrstcr_crn 
  )
  GROUP BY sfrstcr_pidm
  ORDER BY sfrstcr_pidm
)
SELECT 
	spriden_id AS "Student_ID",
	spriden_last_name ||', ' || spriden_first_name AS "Student_Name",
	a1.sorlcur_camp_code AS "College_Code",
	a1.sorlcur_program AS "Programme_Code",
	b1.smrprle_program_desc AS "Programme_Description",
	a1.sorlcur_term_code_admit AS "Admit_Term",
	attr.sgrsatt_atts_code AS "Current_Stage",
	a1.sorlcur_end_date AS "Expected_Completion_Date",
	a1.sorlcur_styp_code AS "Mode_of_Study",
	sfrensp_ests_code AS "Enrolment_Status_Current_Term",
	CASE
		WHEN sfrensp_ests_code = 'AT' THEN a1.sorlcur_leav_from_date
	END AS "Temporary_Withdrawal_Start_Date",
	CASE
		WHEN sfrensp_ests_code = 'AT' THEN a1.sorlcur_leav_to_date
	END AS "Temporary_Withdrawal_End_Date",
	Modules."Module_1",
	Modules."Module_Campus_1",
	Modules."Module_2",
	Modules."Module_Campus_2",
	Modules."Module_3",
	Modules."Module_Campus_3",
	Modules."Module_4",
	Modules."Module_Campus_4",
	Modules."Module_5",
	Modules."Module_Campus_5",
	Modules."Module_6",
	Modules."Module_Campus_6",
	Modules."Module_7",
	Modules."Module_Campus_7",
	Modules."Module_8",
	Modules."Module_Campus_8",
	Modules."Module_9",
	Modules."Module_Campus_9",
	Modules."Module_10",
	Modules."Module_Campus_10"
	
	
FROM 
	sorlcur a1
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
	--LEFT JOIN szrenrl ON a1.sorlcur_pidm = szrenrl_pidm
	JOIN sgrstsp t1 ON a1.sorlcur_pidm = t1.sgrstsp_pidm AND a1.sorlcur_key_seqno = t1.sgrstsp_key_seqno
	JOIN sgbstdn_add t4 ON a1.sorlcur_pidm = t4.sgbstdn_pidm
	JOIN sfrensp ON a1.sorlcur_pidm = sfrensp_pidm AND a1.sorlcur_key_seqno = sfrensp_key_seqno
	JOIN smrprle b1 ON b1.smrprle_program = a1.sorlcur_program
	LEFT JOIN (SELECT * FROM sgrsatt s1 WHERE s1.sgrsatt_term_code_eff = (SELECT MAX(s2.sgrsatt_term_code_eff) FROM sgrsatt s2 WHERE s1.sgrsatt_pidm = s2.sgrsatt_pidm AND s1.sgrsatt_stsp_key_sequence = s2.sgrsatt_stsp_key_sequence AND s2.sgrsatt_term_code_eff <= :current_term_code)) attr
		ON a1.sorlcur_pidm = attr.sgrsatt_pidm AND a1.sorlcur_key_seqno = attr.sgrsatt_stsp_key_sequence 
    LEFT JOIN Modules ON a1.sorlcur_pidm = Modules.sfrstcr_pidm
WHERE
	1=1
	
	-- Exclude Test Students
	AND (spriden_ntyp_code IS NULL OR spriden_ntyp_code != 'TEST')
	
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
	
	-- Limit to students with a completion date in the future
	AND a1.sorlcur_end_date > sysdate
	
	-- Current student status is Active
    AND t4.sgbstdn_term_code_eff = (
        SELECT MAX(e2.sgbstdn_term_code_eff)
        FROM sgbstdn e2
        WHERE t4.sgbstdn_pidm = e2.sgbstdn_pidm
    )
    AND sgbstdn_stst_code = 'AS'
    
    -- Current study path status is Active
    AND t1.sgrstsp_term_code_eff = (
        SELECT MAX(a2.sgrstsp_term_code_eff)
        FROM sgrstsp a2
        WHERE t1.sgrstsp_pidm = a2.sgrstsp_pidm AND t1.sgrstsp_key_seqno = a2.sgrstsp_key_seqno
    )
    AND t1.sgrstsp_stsp_code = 'AS'
    
    -- Exclude on-campus and AIE students
    AND a1.sorlcur_camp_code NOT IN ('AIE','OBO','OBS','DL')
    
    -- Exclude Research students
    AND a1.sorlcur_levl_code != 'RD'
    
    -- Term for enrolment status
    AND sfrensp_term_code = :current_term_code
	
ORDER BY 
	a1.sorlcur_camp_code,
	a1.sorlcur_program,
	attr.sgrsatt_atts_code asc,
	a1.sorlcur_term_code_admit asc
;

SELECT * FROM sfrstcr;
