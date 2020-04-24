SELECT DISTINCT
	spriden_last_name, spriden_first_name, scbcrse_title, sirasgn.* 
FROM 
	sirasgn
	JOIN spriden ON sirasgn_pidm = spriden_pidm AND spriden_change_ind IS NULL 
	JOIN sirdpcl ON sirasgn_pidm = sirdpcl_pidm
	JOIN ssbsect ON sirasgn_crn = ssbsect_crn AND sirasgn_term_code = ssbsect_term_code
	JOIN scbcrse ON ssbsect_subj_code = scbcrse_subj_code AND ssbsect_crse_numb = scbcrse_crse_numb
WHERE 
	sirdpcl_coll_code = 'AS'
ORDER BY
	spriden_last_name,
	spriden_first_name
;