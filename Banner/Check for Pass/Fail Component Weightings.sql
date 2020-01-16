SELECT 
    ssbsect_term_code, 
    ssbsect_crn, 
    ssbsect_subj_code, 
    ssbsect_crse_numb, 
    ssbsect_gsch_name, 
    shrgcom.*
FROM 
    shrgcom
    JOIN ssbsect ON shrgcom_crn = ssbsect_crn AND shrgcom_term_code = ssbsect_term_code
WHERE
    1=1
    AND shrgcom_grade_scale = 'PASS/FAIL' 
    AND shrgcom_weight > 0
    --AND ssbsect_gsch_name != 'PASS/FAIL'
;