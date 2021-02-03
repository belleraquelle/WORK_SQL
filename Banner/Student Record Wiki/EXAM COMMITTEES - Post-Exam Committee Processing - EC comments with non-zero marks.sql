/*
 * This query returns any assessment component has an exceptional circumstances
 * comment but also has a non-zero mark entered at first attempt (i.e. resits are excluded)
 * 
 * These need to be zeroed out. 
 *
 * 
 */

SELECT 
  spriden_id,
  shrmrks_term_code, 
  shrmrks_crn,
  ssbsect_subj_code,
  ssbsect_crse_numb,
  shrmrks_gcom_id,
  shrmrks_percentage,
  shrmrks_grde_code,
  shrmrks_comments
FROM 
  shrmrks
  JOIN spriden ON shrmrks_pidm = spriden_pidm AND spriden_change_ind IS NULL
  JOIN ssbsect ON shrmrks_term_code = ssbsect_term_code AND shrmrks_crn = ssbsect_crn
WHERE
  1=1
  AND (shrmrks_percentage > 0 OR shrmrks_grde_code = 'S')
  AND shrmrks_comments = 'Exceptional Circumstances'
  AND shrmrks_gchg_code NOT IN (SELECT stvgchg_code FROM stvgchg WHERE stvgchg_reas_grde_ind = 'Y')
  AND ssbsect_ptrm_end_date BETWEEN :module_end_date_range_start AND :module_end_date_range_end	
;