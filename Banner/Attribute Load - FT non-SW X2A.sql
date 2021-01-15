/*
 * Attribute Loading - X2A for FT non-SW students
 * 
 */

SELECT DISTINCT
    d1.spriden_id AS "Student_ID",
    z1.sgrstsp_pidm AS "Student_PIDM",
    z1.sgrstsp_key_seqno AS "Study_Path",
    t2.sorlcur_program AS "Programme",
    t2.sorlcur_degc_code AS "Award_Type",
    t2.sorlcur_styp_code AS "Mode_of_Study",
    a2.sgrsatt_atts_code AS "Current_Attribute_Code"
FROM
    sgrstsp z1
    JOIN sorlcur t2 ON (z1.sgrstsp_pidm = t2.sorlcur_pidm AND z1.sgrstsp_key_seqno = t2.sorlcur_key_seqno)
    JOIN sorlfos t3 ON (t2.sorlcur_pidm = t3.sorlfos_pidm AND t2.sorlcur_seqno = t3.sorlfos_lcur_seqno)
    JOIN spriden d1 ON (z1.sgrstsp_pidm = d1.spriden_pidm)
    JOIN sgbstdn_add t4 ON (z1.sgrstsp_pidm = t4.sgbstdn_pidm)
    JOIN smrpaap s1 ON t2.sorlcur_program = smrpaap_program AND smrpaap_term_code_eff = (
    	SELECT MAX(s2.smrpaap_term_code_eff)
    	FROM smrpaap s2
    	WHERE
    		s1.smrpaap_program = s2.smrpaap_program AND s2.smrpaap_term_code_eff <= :admit_term
    )
    JOIN smralib ON s1.smrpaap_area = smralib_area
    JOIN sgrsatt a2 ON t2.sorlcur_pidm = a2.sgrsatt_pidm AND t2.sorlcur_key_seqno = a2.sgrsatt_stsp_key_sequence AND a2.sgrsatt_term_code_eff = :admit_term
    
WHERE
    1=1
  
	-- CURRENT STUDENT NUMBER AND NOT TEST
    AND d1.spriden_change_ind IS NULL
    AND (d1.spriden_ntyp_code IS NULL OR d1.spriden_ntyp_code != 'TEST')
    
	-- IDENTIFY STUDENTS WITH ACTIVE STUDY PATHS
    AND z1.sgrstsp_term_code_eff = (
        SELECT MAX(a2.sgrstsp_term_code_eff)
        FROM sgrstsp a2
        WHERE z1.sgrstsp_pidm = a2.sgrstsp_pidm AND z1.sgrstsp_key_seqno = a2.sgrstsp_key_seqno
    )
    AND z1.sgrstsp_stsp_code = 'AS'
    
	-- ONLY INCLUDE STUDY PATHS WITH A COMPLETION DATE BEYOND TODAY
    AND t2.sorlcur_term_code = (
        SELECT MAX(b2.sorlcur_term_code)
        FROM sorlcur b2
        WHERE t2.sorlcur_pidm = b2.sorlcur_pidm AND t2.sorlcur_key_seqno = b2.sorlcur_key_seqno
        AND t2.sorlcur_lmod_code = 'LEARNER' AND t2.sorlcur_end_date >= sysdate
    )
    AND t2.sorlcur_lmod_code = 'LEARNER' AND t2.sorlcur_end_date > sysdate
    AND t2.sorlcur_camp_code NOT IN ('AIE')
    
	-- LIMIT TO CURRENT SGBSTDN RECORD
    AND t4.sgbstdn_term_code_eff = (
        SELECT MAX(e2.sgbstdn_term_code_eff)
        FROM sgbstdn e2
        WHERE t4.sgbstdn_pidm = e2.sgbstdn_pidm
    )
    AND sgbstdn_stst_code = 'AS'
    
	-- ONLY INCLUDE PROPER SORLCUR RECORDS
    AND t3.SORLFOS_csts_code = 'INPROGRESS'
    AND t2.sorlcur_current_cde = 'Y'
    AND t2.sorlcur_term_code_end IS NULL
    
	-- LIMIT TO NEW STUDENTS
    AND t2.sorlcur_term_code_admit = :admit_term
    
    -- Limit to students on programmes with progression stage X attributes
    AND smralib_atts_code IN ('X2','X2A')
    
    -- Limit to full-time students
    AND t2.sorlcur_styp_code = 'F'
    
    -- Exclude Sandwich students
    
    AND  z1.sgrstsp_pidm || z1.sgrstsp_key_seqno NOT IN (
    	SELECT c1.sgrchrt_pidm || c1.sgrchrt_stsp_key_sequence
    	FROM sgrchrt c1
    	WHERE
    		c1.sgrchrt_term_code_eff = (
    		SELECT MAX(c2.sgrchrt_term_code_eff)
    		FROM sgrchrt c2
    		WHERE c1.sgrchrt_pidm = c2.sgrchrt_pidm AND c1.sgrchrt_stsp_key_sequence = c2.sgrchrt_stsp_key_sequence
    		) 
    		AND c1.sgrchrt_chrt_code = 'SW' 
    		AND sgrchrt_active_ind IS NULL
    )
    
    -- Limit to students without an attribute for the next AY
    AND  z1.sgrstsp_pidm || z1.sgrstsp_key_seqno NOT IN (
    	SELECT a1.sgrsatt_pidm || a1.sgrsatt_stsp_key_sequence
    	FROM sgrsatt a1
    	WHERE 
    		a1.sgrsatt_term_code_eff = (CAST(SUBSTR(:admit_term, 1, 4) AS Integer) + 1) || SUBSTR(:admit_term, -2, 2)
    )
    
    -- Limit to students with an X1 attribute against the admit term i.e. exclude credit entry
    AND a2.sgrsatt_atts_code = 'X1'
    
 ORDER BY 
 	t2.sorlcur_program,
 	d1.spriden_id
 ;
 
SELECT * FROM sorlcur;