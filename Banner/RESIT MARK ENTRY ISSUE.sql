SELECT 
	SHRMRKS_TERM_CODE,	
	SHRMRKS_CRN	SPRIDEN_ID,	
	SHRMRKS_PIDM,	
	SHRMRKS_GCOM_ID,	
	SHRMRKS_USER_ID,	
	SHRMRKS_PERCENTAGE,	
	SHRMRKS_GRDE_CODE,	
	SHRMRKS_GCHG_CODE,	
	SHRMRKS_ACTIVITY_DATE,	
	SHRCMRK_ACTIVITY_DATE,	
	SHRCMRK_PERCENTAGE,	
	SHRCMRK_GRDE_CODE
	
FROM 
	shrmrks
	JOIN shrcmrk ON shrmrks_term_code = shrcmrk_term_code AND shrmrks_crn = shrcmrk_crn AND shrmrks_pidm = shrcmrk_pidm
WHERE
	1=1
	AND shrmrks_gchg_code IN ('UR', 'RE', 'CR')
	AND shrmrks_activity_date >= '01-APR-20'
	AND NOT shrcmrk_activity_date >= '01-APR-20'
	AND shrmrks_grde_code NOT IN ('F', 'FAIL')
;


SELECT
	*
FROM 
	shrcmrk
;