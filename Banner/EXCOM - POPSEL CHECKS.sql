SELECT 
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
	szrprop
	JOIN spriden ON pidm = spriden_pidm AND spriden_change_ind IS NULL
	JOIN glbextr ON pidm = glbextr_key
	JOIN sgrstsp g1 ON pidm = g1.sgrstsp_pidm AND study_path = sgrstsp_key_seqno
	JOIN sorlcur b1 ON pidm = b1.sorlcur_pidm AND g1.sgrstsp_key_seqno = b1.sorlcur_key_seqno
	
WHERE
	1=1
	AND glbextr_selection = '202006-UG-GRADUATING'
	AND glbextr_user_id = 'P0076032'
		
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
	
	--AND b1.sorlcur_end_date BETWEEN '01-JAN-20' AND '31-JUL-20'
	
	AND spriden_id = '17072787'
;

SELECT * FROM szrprop JOIN spriden ON pidm = spriden_pidm WHERE spriden_id = '16032150';

SELECT glbextr.* FROM glbextr JOIN spriden ON glbextr_key = spriden_pidm WHERE spriden_id = '17072787' AND glbextr_application = 'EXAM';

SELECT * FROM spriden WHERE spriden_pidm = '1260331';


/*
MERGE INTO GLBEXTR A USING (
*/
SELECT spriden_pidm c1 , 
:popsel_name c2 , 
:popsel_user c3 , 
:popsel_application c4 , 
:popsel_creator c5 , 
sysdate c6 
 FROM SPRIDEN t1 
 WHERE spriden_id = :student_id
/*
) B ON (A.GLBEXTR_KEY= B.c1
 AND A.GLBEXTR_SELECTION= B.c2
 AND A.GLBEXTR_USER_ID= B.c3
 AND A.GLBEXTR_APPLICATION= B.c4
 AND A.GLBEXTR_CREATOR_ID= B.c5) WHEN NOT MATCHED THEN INSERT (A.GLBEXTR_KEY
, A.GLBEXTR_SELECTION
, A.GLBEXTR_USER_ID
, A.GLBEXTR_APPLICATION
, A.GLBEXTR_CREATOR_ID
, A.GLBEXTR_ACTIVITY_DATE) VALUES (B.c1
, B.c2
, B.c3
, B.c4
, B.c5
, B.c6)
WHEN MATCHED THEN UPDATE SET A.GLBEXTR_ACTIVITY_DATE= B.c6;
*/
 
 ;

 SELECT * FROM spriden WHERE spriden_id = '15050630'