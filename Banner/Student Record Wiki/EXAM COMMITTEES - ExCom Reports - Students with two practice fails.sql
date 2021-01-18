/*
 * This query identifies students who have two or more failed 'PRAC' CRNS in academic history on a single study path
 * Can be limited by Exam Committee popsel to help identify students who might need to be exited / dropped to a lower award
 */



SELECT
    spriden_id AS "Student_Number",
    spriden_first_name ||' ' || spriden_last_name AS "Student_Name",
    shrtckn_stsp_key_sequence AS "Study_Path",
    a1.sorlcur_program AS "Learner_Programme",
    b1.sorlcur_program AS "Outcome_Programme",
--    shrtckn_crn,
--    shrtckn_subj_code,
--    shrtckn_crse_numb
    COUNT(DISTINCT shrtckn_crn) AS "Number_of_Practice_Fails"
FROM
    shrtckg s1
    JOIN shrtckn ON shrtckn_seq_no = shrtckg_tckn_seq_no AND shrtckn_pidm = s1.shrtckg_pidm AND shrtckn_term_code = s1.shrtckg_term_code
    JOIN spriden ON shrtckn_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN scrattr ON shrtckn_subj_code = scrattr_subj_code AND shrtckn_crse_numb = scrattr_crse_numb
    JOIN shrtckl ON shrtckn_pidm = shrtckl_pidm AND shrtckn_term_code = shrtckl_term_code AND shrtckn_seq_no = shrtckl_tckn_seq_no
    JOIN shrgrde ON shrtckg_grde_code_final = shrgrde_code AND shrtckl_levl_code = shrgrde_levl_code
    JOIN sorlcur a1 ON shrtckg_pidm = a1.sorlcur_pidm AND shrtckn_stsp_key_sequence = a1.sorlcur_key_seqno
    LEFT JOIN shrdgmr ON a1.sorlcur_pidm = shrdgmr_pidm AND shrtckn_stsp_key_sequence = shrdgmr_stsp_key_sequence
    LEFT JOIN sorlcur b1 ON shrdgmr_pidm = b1.sorlcur_pidm AND shrdgmr_seq_no = b1.sorlcur_key_seqno
    
WHERE 
    1=1

    -- Pick the latest grade for each module in Academic History
    AND s1.shrtckg_seq_no = (SELECT MAX(s2.shrtckg_seq_no) FROM shrtckg s2 WHERE s2.shrtckg_pidm = s1.shrtckg_pidm AND s2.shrtckg_term_code = s1.shrtckg_term_code AND s2.shrtckg_tckn_seq_no = s1.shrtckg_tckn_seq_no)
    
    -- Identify Practice Modules
    AND scrattr_attr_code = 'PRAC'
    
    -- Limit to 'Failing' grades
    AND (shrgrde_attempted_ind = 'Y' AND shrgrde_passed_ind = 'N')
    
    -- Exclude IC grades
    AND shrtckg_grde_code_final != 'IC'
    
    -- Pick out latest learner curricula
    AND a1.sorlcur_term_code = (
    	SELECT MAX(a2.sorlcur_term_code)
    	FROM sorlcur a2
    	WHERE a1.sorlcur_pidm = a2.sorlcur_pidm AND a1.sorlcur_key_seqno = a2.sorlcur_key_seqno AND a1.sorlcur_lmod_code = a2.sorlcur_lmod_code
    )
    AND a1.sorlcur_lmod_code = 'LEARNER'
    AND a1.sorlcur_current_cde = 'Y'
    AND a1.sorlcur_cact_code = 'ACTIVE'
    
    -- Pick out latest outcome curricula
    AND ((b1.sorlcur_seqno = (
    	SELECT MAX(b2.sorlcur_seqno)
    	FROM sorlcur b2
    	WHERE b1.sorlcur_pidm = b2.sorlcur_pidm AND b1.sorlcur_key_seqno = b2.sorlcur_key_seqno AND b1.sorlcur_lmod_code = b2.sorlcur_lmod_code
    )
    AND b1.sorlcur_lmod_code = 'OUTCOME'
    AND b1.sorlcur_current_cde = 'Y'
    AND b1.sorlcur_cact_code = 'ACTIVE') OR b1.sorlcur_seqno IS NULL)
    
    -- Limit to students in specified popsel
    AND spriden_pidm in (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = :popsel_name AND glbextr_user_id = :popsel_user)

GROUP BY 
	spriden_id,
    spriden_first_name ||' ' || spriden_last_name,
    shrtckn_stsp_key_sequence,
    a1.sorlcur_program,
    b1.sorlcur_program

HAVING 
	COUNT(DISTINCT shrtckn_crn) >= 2
	
ORDER BY 
	a1.sorlcur_program

;