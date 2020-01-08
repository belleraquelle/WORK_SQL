/*

This SQL will pick out any components that are flagged as MUST PASS
with a pass mark lower than normal (40% UG and 50% PG)

*/

SELECT 
    * 
FROM 
    shrgcom 
WHERE 
    (shrgcom_pass_ind = 'Y' AND shrgcom_min_pass_score < 50 AND shrgcom_grade_scale = 'POSTGRAD') 
    OR 
    (shrgcom_pass_ind = 'Y' AND shrgcom_min_pass_score < 40 AND shrgcom_grade_scale = 'UNDERGRAD')
;