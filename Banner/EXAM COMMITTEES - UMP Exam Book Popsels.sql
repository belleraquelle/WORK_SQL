-- GOLD BOOK SELECTION
SELECT DISTINCT
	spriden_pidm
FROM
	spriden
WHERE
	--UMP students with an end date between the dates specified
	spriden_pidm IN 
		(
		SELECT
			spriden_pidm
		FROM
			sorlcur t1,
			sobcurr_add,
			spriden
		WHERE
			1=1
			AND sorlcur_curr_rule = sobcurr_curr_rule
			AND sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
			AND t1.sorlcur_term_code = (
		        SELECT MAX(t2.sorlcur_term_code)
		        FROM sorlcur t2
		        WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER')
		    AND t1.sorlcur_current_cde = 'Y'
		    AND t1.sorlcur_cact_code = 'ACTIVE'
			AND t1.sorlcur_term_code_end IS NULL
			AND t1.sorlcur_lmod_code = 'LEARNER'
			AND ump_1 = 'Y'
			AND sorlcur_end_date BETWEEN '01-DEC-2019' AND '20-JAN-2020'
			
		)
		--UMP students with a pending award status
		OR spriden_pidm IN
			(
			SELECT
				spriden_pidm
			FROM 
				shrdgmr,
				sorlcur,
				sobcurr_add,
				spriden
			WHERE 
				1=1
				AND shrdgmr_pidm = sorlcur_pidm AND shrdgmr_seq_no = sorlcur_key_seqno AND sorlcur_lmod_code = 'OUTCOME'
				AND shrdgmr_pidm = spriden_pidm AND spriden_change_ind IS NULL
				AND sorlcur_curr_rule = sobcurr_curr_rule
				AND ump_1 = 'Y'
				AND shrdgmr_degs_code = 'PN'
			)
;

--PINK BOOK SELECTION
SELECT DISTINCT
	a1.sorlcur_pidm,
    spriden_id, 
    a1.sorlcur_key_seqno,
    a1.sorlcur_program
FROM
	sorlcur a1,
	sobcurr_add,
    sgbstdn t1,
    sgrstsp v1,
    spriden
WHERE
	1=1
    AND sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
	AND sorlcur_curr_rule = sobcurr_curr_rule
    AND a1.sorlcur_pidm = t1.sgbstdn_pidm
    AND a1.sorlcur_pidm = v1.sgrstsp_pidm AND a1.sorlcur_key_seqno = v1.sgrstsp_key_seqno
	AND a1.sorlcur_term_code = (
		        SELECT MAX(a2.sorlcur_term_code)
		        FROM sorlcur a2
		        WHERE a2.sorlcur_pidm = a1.sorlcur_pidm AND a2.sorlcur_key_seqno = a1.sorlcur_key_seqno AND a2.sorlcur_lmod_code = 'LEARNER')
	AND a1.sorlcur_current_cde = 'Y'
	AND a1.sorlcur_cact_code = 'ACTIVE'
	AND a1.sorlcur_lmod_code = 'LEARNER'
    AND a1.sorlcur_term_code_end IS NULL
    AND a1.sorlcur_term_code_admit <= '201909'
    AND t1.sgbstdn_term_code_eff = (
				SELECT MAX(t2.sgbstdn_term_code_eff)
		        FROM sgbstdn t2
		        WHERE t1.sgbstdn_pidm = t2.sgbstdn_pidm
			)
    AND t1.sgbstdn_stst_code = 'AS'
    AND v1.sgrstsp_term_code_eff = (
		        SELECT MAX(v2.sgrstsp_term_code_eff)
		        FROM sgrstsp v2
		        WHERE v1.sgrstsp_pidm = v2.sgrstsp_pidm AND v1.sgrstsp_key_seqno = v2.sgrstsp_key_seqno
		    )
    AND v1.sgrstsp_stsp_code = 'AS'
	AND ump_1 = 'Y'
	--Students on a current X1 attribute or currently on a Foundation Year
	AND (sorlcur_pidm||sorlcur_key_seqno IN (
		SELECT
			s1.sgrsatt_pidm||s1.sgrsatt_stsp_key_sequence
		FROM
			sgrsatt s1
		WHERE
			1=1
			AND s1.sgrsatt_term_code_eff <= '201909' AND s1.sgrsatt_atts_code = 'X1'
			AND s1.sgrsatt_pidm NOT IN
				(SELECT s2.sgrsatt_pidm FROM sgrsatt s2 WHERE s1.sgrsatt_pidm = s2.sgrsatt_pidm AND s1.sgrsatt_stsp_key_sequence = s2.sgrsatt_stsp_key_sequence AND s2.sgrsatt_term_code_eff <= '201909' AND s2.sgrsatt_atts_code IN ('X2', 'X3','SW'))
	)
    OR a1.sorlcur_program IN ('FNDIP-FBE','FNDIP-FBU','FNDIP-FCO','FNDIP-FEG','FNDIP-FHU','FNDIP-FLL', 'FNDIP-LSF')
    )
;

--SILVER BOOK SELECTION
SELECT DISTINCT
	a1.sorlcur_pidm,
    spriden_id, 
    a1.sorlcur_key_seqno,
    a1.sorlcur_program
FROM
	sorlcur a1,
	sobcurr_add,
    sgbstdn t1,
    sgrstsp v1,
    spriden
WHERE
	1=1
    AND sorlcur_pidm = spriden_pidm AND spriden_change_ind IS NULL
	AND sorlcur_curr_rule = sobcurr_curr_rule
    AND a1.sorlcur_pidm = t1.sgbstdn_pidm
    AND a1.sorlcur_pidm = v1.sgrstsp_pidm AND a1.sorlcur_key_seqno = v1.sgrstsp_key_seqno
	AND a1.sorlcur_term_code = (
		        SELECT MAX(a2.sorlcur_term_code)
		        FROM sorlcur a2
		        WHERE a2.sorlcur_pidm = a1.sorlcur_pidm AND a2.sorlcur_key_seqno = a1.sorlcur_key_seqno AND a2.sorlcur_lmod_code = 'LEARNER')
	AND a1.sorlcur_current_cde = 'Y'
	AND a1.sorlcur_cact_code = 'ACTIVE'
	AND a1.sorlcur_lmod_code = 'LEARNER'
    AND a1.sorlcur_term_code_end IS NULL
    AND a1.sorlcur_term_code_admit <= '201909'
    -- Only include students with an end date after the UCF
    AND a1.sorlcur_end_date > '20-JAN-2020'
    AND t1.sgbstdn_term_code_eff = (
				SELECT MAX(t2.sgbstdn_term_code_eff)
		        FROM sgbstdn t2
		        WHERE t1.sgbstdn_pidm = t2.sgbstdn_pidm
			)
    AND t1.sgbstdn_stst_code = 'AS'
    AND v1.sgrstsp_term_code_eff = (
		        SELECT MAX(v2.sgrstsp_term_code_eff)
		        FROM sgrstsp v2
		        WHERE v1.sgrstsp_pidm = v2.sgrstsp_pidm AND v1.sgrstsp_key_seqno = v2.sgrstsp_key_seqno
		    )
    AND v1.sgrstsp_stsp_code = 'AS'
	AND ump_1 = 'Y'
	--Exclude students on a current X1 attribute or currently on a Foundation Year
	AND (sorlcur_pidm||sorlcur_key_seqno NOT IN (
		SELECT
			s1.sgrsatt_pidm||s1.sgrsatt_stsp_key_sequence
		FROM
			sgrsatt s1
		WHERE
			1=1
			AND s1.sgrsatt_term_code_eff <= '201909' AND s1.sgrsatt_atts_code = 'X1'
			AND s1.sgrsatt_pidm NOT IN
				(SELECT s2.sgrsatt_pidm FROM sgrsatt s2 WHERE s1.sgrsatt_pidm = s2.sgrsatt_pidm AND s1.sgrsatt_stsp_key_sequence = s2.sgrsatt_stsp_key_sequence AND s2.sgrsatt_term_code_eff <= '201909' AND s2.sgrsatt_atts_code IN ('X2', 'X3','SW'))
		)
    	AND a1.sorlcur_program NOT IN ('FNDIP-FBE','FNDIP-FBU','FNDIP-FCO','FNDIP-FEG','FNDIP-FHU','FNDIP-FLL', 'FNDIP-LSF')
    )
    -- Exclude students with pending awards
    AND sorlcur_pidm NOT IN (
        SELECT
            spriden_pidm
        FROM 
    		shrdgmr,
			sorlcur,
            sobcurr_add,
            spriden
        WHERE 
            1=1
            AND shrdgmr_pidm = sorlcur_pidm AND shrdgmr_seq_no = sorlcur_key_seqno AND sorlcur_lmod_code = 'OUTCOME'
            AND shrdgmr_pidm = spriden_pidm AND spriden_change_ind IS NULL
            AND sorlcur_curr_rule = sobcurr_curr_rule
            AND ump_1 = 'Y'
            AND shrdgmr_degs_code = 'PN'
    )
;