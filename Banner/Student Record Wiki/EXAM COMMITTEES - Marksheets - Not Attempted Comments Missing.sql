/*
 * This query returns any assessment component on a module that ends between the dates
 * specified and where the component has a mark of 0 and no Grade Comment.
 * 
 * In these instances, we need Exam Committees to confirm whether or not the student attempted
 * the assessment. 
 *
 * 
 */

SELECT 
  s1.spriden_id,
  shrmrks_term_code, 
  shrmrks_crn,
  ssbsect_subj_code,
  ssbsect_crse_numb,
  shrmrks_gcom_id,
  shrmrks_percentage,
  shrmrks_grde_code,
  shrmrks_comments,
  shrmrks_roll_date,
  s2.spriden_last_name || ', ' || s2.spriden_first_name AS "Module_Leader",
  s2.spriden_id
FROM 
  shrmrks
  JOIN spriden s1 ON shrmrks_pidm = s1.spriden_pidm AND s1.spriden_change_ind IS NULL
  JOIN ssbsect ON shrmrks_term_code = ssbsect_term_code AND shrmrks_crn = ssbsect_crn
  LEFT JOIN sirasgn ON sirasgn_term_code = ssbsect_term_code AND sirasgn_crn = ssbsect_crn AND sirasgn_primary_ind = 'Y'
  LEFT JOIN spriden s2 ON sirasgn_pidm = s2.spriden_pidm
WHERE
  1=1
  AND shrmrks_percentage = 0
  AND shrmrks_comments IS NULL
  AND shrmrks_gchg_code NOT IN (SELECT stvgchg_code FROM stvgchg WHERE stvgchg_reas_grde_ind = 'Y')
  AND ssbsect_ptrm_end_date BETWEEN :module_end_date_range_start AND :module_end_date_range_end
  AND s2.spriden_id LIKE 'P%'
;

SELECT * FROM shrmrks;