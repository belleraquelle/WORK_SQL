/*
This query identifies those module registrations where there is a mismatch between the curriculum campus and the campus
on a student's module registration. This implies that either the student's curriculum is on the wrong campus, or that 
the student is registered on the wrong section.
*/


SELECT
    sfrstcr_pidm AS "Student_PIDM",
    spriden_id AS "Student_ID",
    sfrstcr_term_code AS "Term_Code", 
    sfrstcr_crn AS "CRN",
    ssbsect_subj_code AS "Subject",
    ssbsect_crse_numb AS "Course_Number",
    sfrstcr_rsts_code AS "Module_Registration_Status",
    ssbsect_camp_code AS "Section_Campus_Code",
    t1.sorlcur_camp_code AS "Curriculum_Campus_Code"
FROM
    sfrstcr
    JOIN ssbsect ON sfrstcr_term_code = ssbsect_term_code AND sfrstcr_crn = ssbsect_crn
    JOIN sorlcur t1 ON sfrstcr_pidm = t1.sorlcur_pidm AND sfrstcr_stsp_key_sequence = t1.sorlcur_key_seqno AND t1.sorlcur_lmod_code = 'LEARNER' AND t1.sorlcur_current_cde = 'Y'
    JOIN spriden ON sfrstcr_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
    1=1
    
    -- Return records where the section and curriculum campuses don't match
    AND ssbsect_camp_code != sorlcur_camp_code
    
    -- Exclude fee modules
    AND ssbsect_subj_code != 'FEE'
    
    -- Only include modules that are registered
    AND sfrstcr_rsts_code IN ('RE','RW')
    
    -- Return the curriculum record within which the module registration falls
    AND sorlcur_term_code <= sfrstcr_term_code AND (sorlcur_term_code_end IS NULL OR sorlcur_term_code_end > sfrstcr_term_code)
    
ORDER BY 
    spriden_id
;