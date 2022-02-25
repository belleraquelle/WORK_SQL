/*
 Identifies students who are enrolled with no modules who may need to be data tidied.
 Updated 25th February 2021 SRC
 */

SELECT DISTINCT
    sorlcur_term_code_admit AS "Admit_Term",
    spriden_id AS "Student_Number", 
    spriden_last_name || ', ' || spriden_first_name AS "Student_Name",
    sorlcur_camp_code AS "Campus",
    sorlcur_program AS "Programme_Code",
    smrprle_program_desc AS "Programme_Description",
    sfbetrm_term_code AS "Enrolment_Term", 
    sfbetrm_ests_code AS "Overall_Enrolment_Status", 
    sfrensp_key_seqno AS "Study_Path",  
    sfrensp_ests_code AS "Study_Path_Enrolment_Status"  
FROM
    sfbetrm
    JOIN sfrensp ON sfbetrm_pidm = sfrensp_pidm AND sfbetrm_term_code = sfrensp_term_code
    JOIN spriden ON sfbetrm_pidm = spriden_pidm AND spriden_change_ind IS NULL
    JOIN sorlcur ON sfrensp_pidm = sorlcur_pidm AND sfrensp_key_seqno = sorlcur_key_seqno AND sorlcur_lmod_code = 'LEARNER'
    JOIN stvterm ON sfbetrm_term_code = stvterm_code
    JOIN smrprle ON sorlcur_program = smrprle_program
WHERE
    1=1
    AND sfbetrm_term_code = :term_code
    AND sfbetrm_ests_code = 'EN'
    AND sfbetrm_pidm NOT IN (
        SELECT DISTINCT sfrstcr_pidm
        FROM sfrstcr JOIN ssbsect ON sfrstcr_term_code = ssbsect_term_code AND sfrstcr_crn = ssbsect_crn
        WHERE 
            1=1
            AND (
                -- Modules ending in current semester
                (ssbsect_ptrm_end_date BETWEEN stvterm_start_date AND stvterm_end_date) OR 
                
                -- Modules starting within the current semester
                (ssbsect_ptrm_start_date BETWEEN stvterm_start_date AND stvterm_end_date) OR
                
                -- Modules starting before and ending after the current semester
                (ssbsect_ptrm_start_date < stvterm_start_date AND ssbsect_ptrm_end_date > stvterm_end_date)
                
                )
            AND sfrstcr_rsts_code IN ('RE','RW','RC')
            )
    AND sorlcur_camp_code NOT IN ('AIE', 'OCE', 'HKM')
    AND sorlcur_levl_code != 'RD'
    AND sorlcur_program NOT IN ('PGC-SEY', 'PGC-SEZ', 'GRD-HKL','LLBH-LLB')
    --AND sorlcur_term_code_admit = '201909'
    AND spriden_pidm NOT IN ( 
        SELECT glbextr_key FROM glbextr WHERE glbextr_selection = :popsel
    )
ORDER BY
    "Campus",
    "Programme_Code",
    "Student_Name"
;


SELECT * FROM glbextr;