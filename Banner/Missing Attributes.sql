SELECT DISTINCT
	spriden_id AS "Student_Number", 
	t1.sorlcur_styp_code AS "Mode_of_Study", 
	t1.sorlcur_program AS "Course",
	sfbetrm_ests_code AS "Enrolment_Status",
	t1.sorlcur_term_code_admit AS "Admit_Term"
	
FROM 
	sgrsatt
	JOIN spriden ON sgrsatt_pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN sorlcur t1 ON sgrsatt_pidm = t1.sorlcur_pidm AND sgrsatt_stsp_key_sequence = t1.sorlcur_key_seqno
	JOIN smrpaap u1 ON sorlcur_program = u1.smrpaap_program AND u1.smrpaap_term_code_eff = (SELECT MAX(u2.smrpaap_term_code_eff) FROM smrpaap u2 WHERE u1.smrpaap_program = u2.smrpaap_program)
	LEFT JOIN sfbetrm ON sgrsatt_pidm = sfbetrm_pidm AND sfbetrm_term_code = :current_term
	
WHERE
	1=1
	
-- Limit to records where the course utilises the specified attribute within their structure e.g. S2
	AND EXISTS (SELECT * FROM smralib WHERE smrpaap_area = smralib_area AND smralib_atts_code = :future_attribute)
	
-- Pull out the students who DON'T have that attribute
	AND sgrsatt_pidm || sgrsatt_stsp_key_sequence NOT IN (
		SELECT sgrsatt_pidm || sgrsatt_stsp_key_sequence
		FROM sgrsatt 
		WHERE 
			1=1
			AND sgrsatt_atts_code = :future_attribute
	)
	
-- Limit to 'Active' students
	AND sgrsatt_pidm IN (
		SELECT sgbstdn_pidm
		FROM sgbstdn s1
		WHERE 
			1=1
			AND s1.sgbstdn_term_code_eff = (SELECT MAX (s2.sgbstdn_term_code_eff) FROM sgbstdn s2 WHERE s1.sgbstdn_pidm = s2.sgbstdn_pidm)
			AND s1.sgbstdn_stst_code = 'AS'
	)
	
-- Pick out maximum, active, learner SORLCUR record
	AND t1.sorlcur_term_code = (SELECT MAX(t2.sorlcur_term_code) FROM sorlcur t2 WHERE t1.sorlcur_pidm = t2.sorlcur_pidm AND t1.sorlcur_key_seqno = t2.sorlcur_key_seqno AND t2.sorlcur_cact_code = 'ACTIVE' AND t2.sorlcur_current_cde = 'Y' AND t2. sorlcur_lmod_code = 'LEARNER')
	AND t1.sorlcur_cact_code = 'ACTIVE'
	AND t1.sorlcur_current_cde = 'Y'
	AND t1.sorlcur_lmod_code = 'LEARNER'
	
-- Limit to specified mode of study
	AND t1.sorlcur_styp_code = :mode_of_study
	
-- Limit to students with an expected completion date in the future
	AND t1.sorlcur_end_date > sysdate
	
-- Exclude MPHILs
	AND t1.sorlcur_program NOT LIKE 'MPHIL%'
	
-- Limit to students with specified admit term
	--AND t1.sorlcur_term_code_admit = '201909'
	
-- Limit to students who are currently enrolled
	AND sfbetrm_ests_code = 'EN'
	
-- If SW attribute is being checked, then only include students who have an active SW cohort
	AND CASE
			WHEN :future_attribute = 'SW' AND sgrsatt_pidm || sgrsatt_stsp_key_sequence IN (
				SELECT 
					a1.sgrchrt_pidm || a1.sgrchrt_stsp_key_sequence 
				FROM 
					sgrchrt a1
				WHERE
					1=1
					AND a1.sgrchrt_chrt_code = 'SW' 
					AND a1.sgrchrt_active_ind IS NULL
					AND a1.sgrchrt_term_code_eff = (
						SELECT MAX(a2.sgrchrt_term_code_eff)
						FROM sgrchrt a2
						WHERE a1.sgrchrt_pidm = a2.sgrchrt_pidm AND a1.sgrchrt_stsp_key_sequence = a2.sgrchrt_stsp_key_sequence
					)
				)
			THEN 1
			WHEN :future_attribute != 'SW' 
			THEN 1
		ELSE 0
		END = 1
	
ORDER BY
	t1.sorlcur_program
;