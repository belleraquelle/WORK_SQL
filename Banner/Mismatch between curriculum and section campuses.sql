/*
This query identifies those module registrations where there is a mismatch between the curriculum campus and the campus
on a student's module registration. This implies that either the student's curriculum is on the wrong campus, or that 
the student is registered on the wrong section.
*/


SELECT
    sfrstcr_pidm AS "Student PIDM",
    spriden_id AS "Student ID",
    sfrstcr_term_code AS "Term Code", 
    sfrstcr_crn AS "CRN",
    ssbsect_subj_code AS "Subject",
    ssbsect_crse_numb AS "Course Number",
    sfrstcr_rsts_code AS "Module Registration Status",
    ssbsect_camp_code AS "Section Campus Code",
    sorlcur_camp_code AS "Curriculum Campus Code"
FROM
    sfrstcr
    JOIN ssbsect ON sfrstcr_term_code = ssbsect_term_code AND sfrstcr_crn = ssbsect_crn
    JOIN sorlcur ON sfrstcr_pidm = sorlcur_pidm AND sfrstcr_stsp_key_sequence = sorlcur_key_seqno AND sorlcur_lmod_code = 'LEARNER' AND sorlcur_current_cde = 'Y'
    JOIN spriden ON sfrstcr_pidm = spriden_pidm AND spriden_change_ind IS NULL
WHERE
    1=1
    AND ssbsect_camp_code != sorlcur_camp_code
    AND ssbsect_subj_code != 'FEE'
    AND sfrstcr_rsts_code 
ORDER BY 
    spriden_id
;