/*
 * This query pulls out current ACP student for checking and verification 
 */

SELECT 
	spriden_id AS "Student_ID",
	spriden_last_name ||', ' || spriden_first_name AS "Student_Name",
	a1.sorlcur_camp_code AS "College_Code",
	a1.sorlcur_program AS "Programme_Code",
	b1.smrprle_program_desc AS "Programme_Description",
	a1.sorlcur_term_code_admit AS "Admit_Term",
	s1.sgrsatt_atts_code AS "Current_Stage",
	a1.sorlcur_end_date AS "Expected_Completion_Date",
	a1.sorlcur_styp_code AS "Mode_of_Study",
	sfrensp_ests_code AS "Enrolment_Status_Current_Term",
	CASE
		WHEN sfrensp_ests_code = 'AT' THEN a1.sorlcur_leav_to_date
	END AS "Temporary_Withdrawal_End_Date"
FROM 
	sorlcur a1
	JOIN spriden ON a1.sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
	--LEFT JOIN szrenrl ON a1.sorlcur_pidm = szrenrl_pidm
	JOIN sgrstsp t1 ON a1.sorlcur_pidm = t1.sgrstsp_pidm AND a1.sorlcur_key_seqno = t1.sgrstsp_key_seqno
	JOIN sgbstdn_add t4 ON a1.sorlcur_pidm = t4.sgbstdn_pidm
	JOIN sfrensp ON a1.sorlcur_pidm = sfrensp_pidm AND a1.sorlcur_key_seqno = sfrensp_key_seqno
	JOIN smrprle b1 ON b1.smrprle_program = a1.sorlcur_program
	LEFT JOIN sgrsatt s1 ON a1.sorlcur_pidm = sgrsatt_pidm AND a1.sorlcur_key_seqno = sgrsatt_stsp_key_sequence 
        AND s1.sgrsatt_term_code_eff = (SELECT MAX(s2.sgrsatt_term_code_eff) FROM sgrsatt s2 WHERE s1.sgrsatt_pidm = s2.sgrsatt_pidm AND s1.sgrsatt_stsp_key_sequence = s2.sgrsatt_stsp_key_sequence AND s2.sgrsatt_term_code_eff <= :current_term_code)
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
	s1.sgrsatt_atts_code asc,
	a1.sorlcur_term_code_admit asc
;