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
			AND sorlcur_lmod_code = 'LEARNER'
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
	spriden_pidm
FROM
	spriden
WHERE
	--Students on a current X1 attribute
	spriden_pidm IN (
		SELECT
			spriden_pidm
		FROM
			sgrsatt s1,
			sgbstdn t1,
			spriden,
			sgrstsp v1
		WHERE
			1=1
			AND s1.sgrsatt_pidm = sgbstdn_pidm
			AND s1.sgrsatt_pidm = spriden_pidm AND spriden_change_ind IS NULL
			AND s1.sgrsatt_term_code_eff <= '201909' AND s1.sgrsatt_atts_code = 'X1'
			AND s1.sgrsatt_pidm = v1.sgrstsp_pidm AND s1.sgrsatt_stsp_key_sequence = v1.sgrstsp_key_seqno
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
			AND s1.sgrsatt_pidm NOT IN
				(SELECT s2.sgrsatt_pidm FROM sgrsatt s2 WHERE s1.sgrsatt_pidm = s2.sgrsatt_pidm AND s1.sgrsatt_stsp_key_sequence = s2.sgrsatt_stsp_key_sequence AND s2.sgrsatt_term_code_eff <= '201909' AND s2.sgrsatt_atts_code IN ('X2', 'X3','SW'))
	)
	OR
	--Foundation Students
	spriden_pidm IN (
		SELECT
			sorlcur_pidm
		FROM 
			sorlcur,
			sgrstsp v1,
			sgbstdn t1
		WHERE
			1=1
			AND sorlcur_key_seqno = v1.sgrstsp_key_seqno
			AND sorlcur_pidm = t1.sgbstdn_pidm
			AND	sorlcur_lmod_code = 'LEARNER'
			AND sorlcur_degc_code = 'FNDIP'
			AND sorlcur_term_code_end IS NULL
			AND sorlcur_camp_code IN ('OBO', 'OBS')
			AND sorlcur_cact_code = 'ACTIVE'
			AND sorlcur_current_cde = 'Y'
			AND v1.sgrstsp_term_code_eff = (
				SELECT MAX(v2.sgrstsp_term_code_eff)
				FROM sgrstsp v2
				WHERE v1.sgrstsp_pidm = v2.sgrstsp_pidm AND v1.sgrstsp_key_seqno = v2.sgrstsp_key_seqno
			)
			AND v1.sgrstsp_stsp_code = 'AS'
			AND t1.sgbstdn_term_code_eff = (
				SELECT MAX(t2.sgbstdn_term_code_eff)
				FROM sgbstdn t2
				WHERE t1.sgbstdn_pidm = t2.sgbstdn_pidm
			)
			AND t1.sgbstdn_stst_code = 'AS'
			AND sorlcur_term_code_admit != '202001'
			AND sorlcur_end_date > = '01-DEC-2019'
            AND sorlcur_term_code_end IS NULL
	)
;

--SILVER BOOK SELECTION
SELECT DISTINCT
	spriden_pidm
FROM
	spriden
WHERE
	--Include UMP students with an end date greater than the one specified
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
			AND sorlcur_lmod_code = 'LEARNER'
			AND ump_1 = 'Y'
			AND sorlcur_end_date > '20-JAN-2020'
		)
		--Exclude any with a pending award status
		AND spriden_pidm NOT IN
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
		--Exclude anyone currently on an X1 or S1 attribute
		AND spriden_pidm NOT IN
			(
			SELECT
				spriden_pidm
			FROM
				sgrsatt s1,
				sgbstdn t1,
				spriden,
				sgrstsp v1
			WHERE
				1=1
				AND s1.sgrsatt_pidm = sgbstdn_pidm
				AND s1.sgrsatt_pidm = spriden_pidm AND spriden_change_ind IS NULL
				AND s1.sgrsatt_term_code_eff <= '201909' AND s1.sgrsatt_atts_code = 'X1'
				AND s1.sgrsatt_pidm = v1.sgrstsp_pidm AND s1.sgrsatt_stsp_key_sequence = v1.sgrstsp_key_seqno
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
				AND s1.sgrsatt_pidm NOT IN
					(SELECT s2.sgrsatt_pidm FROM sgrsatt s2 WHERE s1.sgrsatt_pidm = s2.sgrsatt_pidm AND s1.sgrsatt_stsp_key_sequence = s2.sgrsatt_stsp_key_sequence AND s2.sgrsatt_term_code_eff <= '201909' AND s2.sgrsatt_atts_code IN ('X2', 'X3','SW'))
			)
			--Limit to students with active learner and study path records
			AND spriden_pidm IN
				(
				SELECT
					spriden_pidm
				FROM
					sgrsatt s1,
					sgbstdn t1,
					spriden,
					sgrstsp v1
				WHERE
					1=1
					AND s1.sgrsatt_pidm = sgbstdn_pidm
					AND s1.sgrsatt_pidm = spriden_pidm AND spriden_change_ind IS NULL
					AND s1.sgrsatt_pidm = v1.sgrstsp_pidm AND s1.sgrsatt_stsp_key_sequence = v1.sgrstsp_key_seqno
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
				)
;