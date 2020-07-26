/*
 * Check to see which students are in the popsel but don't have filters populated
 */

SELECT DISTINCT
	spriden_id,
	glbextr_key,
	glbextr_selection,
	study_path,
	g1.sgrstsp_stsp_code,
	population, 
	szrprop_term_code, 
	szrprop_atts_code,
	szrprop_camp_code,
	szrprop_coll_code,
	szrprop_prog_code,
	szrprop_majr_code
FROM 
	glbextr
	JOIN spriden ON glbextr_key = spriden_pidm AND spriden_change_ind IS NULL
	LEFT JOIN szrprop ON glbextr_key = pidm AND glbextr_selection = population
	JOIN sgrstsp g1 ON glbextr_key = g1.sgrstsp_pidm AND study_path = sgrstsp_key_seqno
	JOIN sorlcur b1 ON glbextr_key = b1.sorlcur_pidm AND g1.sgrstsp_key_seqno = b1.sorlcur_key_seqno
	
WHERE
	1=1
	AND glbextr_selection = :popsel_name
		
		-- Select Maximum Study Path Record
	AND g1.sgrstsp_term_code_eff = ( 
	
		SELECT MAX(g2.sgrstsp_term_code_eff)
		FROM sgrstsp g2
		WHERE g1.sgrstsp_pidm = g2.sgrstsp_pidm AND g1.sgrstsp_key_seqno = g2.sgrstsp_key_seqno
	
	)
	
	-- Limit to active study paths
	AND g1.sgrstsp_stsp_code = 'AS'
	
	-- Select Maximum Current SORLCUR record
	AND b1.sorlcur_lmod_code = 'LEARNER'
	AND b1.sorlcur_current_cde = 'Y'
	AND b1.sorlcur_cact_code = 'ACTIVE'
	AND b1.sorlcur_term_code = (
	
		SELECT MAX(b2.sorlcur_term_code)
		FROM sorlcur b2
		WHERE
			1=1
			AND b1.sorlcur_pidm = b2.sorlcur_pidm
			AND b1.sorlcur_key_seqno = b2.sorlcur_key_seqno
			AND b2.sorlcur_lmod_code = 'LEARNER'
			AND b2.sorlcur_current_cde = 'Y'
			AND b2.sorlcur_cact_code = 'ACTIVE'
	
	)
	
	-- Strip out wonky migrated data and old foundation records
	AND b1.sorlcur_end_date > '01-JAN-20'
	AND b1.sorlcur_term_code_end IS NULL
	
	-- Limit to missing filters
	AND (
	
		szrprop_term_code IS NULL 
		OR szrprop_atts_code IS NULL 
		OR szrprop_camp_code IS NULL 
		OR szrprop_coll_code IS NULL
		OR szrprop_prog_code IS NULL
		OR szrprop_majr_code IS NULL
	
	)
	
ORDER BY 
	spriden_id
;

SELECT * FROM szrprop WHERE population = '202007-UG-GRADUATING-RESIT';

SELECT * FROM glbextr WHERE glbextr_selection = '202007-UG-GRADUATING-RESIT';