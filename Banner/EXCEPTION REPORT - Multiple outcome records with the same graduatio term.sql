SELECT 
	spriden_id, shrdgmr_pidm, COUNT(*)
FROM 
	shrdgmr s1
	JOIN spriden ON shrdgmr_pidm = spriden_pidm AND spriden_change_ind IS NULL 
WHERE
	1=1
	AND shrdgmr_stsp_key_sequence IS NOT NULL
	AND shrdgmr_degs_code != 'RE'
    AND shrdgmr_term_code_grad = '202209'
	--AND spriden_id = '16069311'
GROUP BY 
	spriden_id, shrdgmr_pidm
HAVING 
	COUNT(*) > 1;
