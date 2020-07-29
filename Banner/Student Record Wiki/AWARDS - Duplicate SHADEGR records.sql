/*
 * This query identifies students + study paths with more than one outcome record.
 */

SELECT 
	spriden_id, shrdgmr_pidm, shrdgmr_stsp_key_sequence, COUNT(*)
FROM 
	shrdgmr s1
	JOIN spriden ON shrdgmr_pidm = spriden_pidm AND spriden_change_ind IS NULL 
WHERE
	1=1
	AND shrdgmr_stsp_key_sequence IS NOT NULL
	AND shrdgmr_degs_code != 'RE'
	--AND spriden_id = '16069311'
GROUP BY 
	spriden_id, shrdgmr_pidm, shrdgmr_stsp_key_sequence
HAVING 
	COUNT(*) > 1
;