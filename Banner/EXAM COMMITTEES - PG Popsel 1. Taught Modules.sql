

spriden_pidm IN 
		(
    SELECT DISTINCT shrmrks_pidm
FROM
    shrmrks
    JOIN shrgcom ON shrmrks_term_code = shrgcom_term_code AND shrmrks_crn = shrgcom_crn  AND shrmrks_gcom_id = shrgcom_id
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    JOIN sfrstcr ON shrmrks_term_code = sfrstcr_term_code AND shrmrks_crn = sfrstcr_crn AND shrmrks_pidm = sfrstcr_pidm
    JOIN stvrsts ON stvrsts_code = sfrstcr_rsts_code
    JOIN sorlcur s1 ON sfrstcr_pidm = s1.sorlcur_pidm AND sfrstcr_stsp_key_sequence = s1.sorlcur_key_seqno
WHERE
    1=1

    -- Only return module runs that meet these criteria
    AND shrmrks_crn IN (
        SELECT
            ssbsect_crn
        FROM
            ssbsect
            JOIN sobptrm ON ssbsect_term_code = sobptrm_term_code AND ssbsect_ptrm_code = sobptrm_ptrm_code
        WHERE
            1=1

            -- Limit to non-UMP modules

            AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb NOT IN (
                SELECT gorsdav_pk_parenttab
                FROM gorsdav
                WHERE gorsdav_table_name = 'SCBCRKY' AND gorsdav_attr_name = 'UMP' AND sys.ANYDATA.accessvarchar2(gorsdav_value) = 'Y'
            )
            
            -- Limit to non-dissertation modules

            AND CONCAT(ssbsect_subj_code, ssbsect_crse_numb) IN (
                SELECT CONCAT(scrattr_subj_code, scrattr_crse_numb)
                FROM scrattr
                WHERE scrattr_attr_code != 'L7DS'
            )
            
            -- Limit to modules that end between specified dates
            AND sobptrm_end_date BETWEEN :EX_2_TAUGHT_MOD_START AND :EX_3_TAUGHT_MOD_END
        )

    -- Only include students who are still registered on the module
    AND stvrsts_incl_sect_enrl = 'Y'
    
    AND s1.sorlcur_cact_code = 'ACTIVE'
    AND s1.sorlcur_current_cde = 'Y'
    AND s1.sorlcur_lmod_code = 'LEARNER'
    AND s1.sorlcur_term_code = (
    	SELECT MAX(s2.sorlcur_term_code)
    	FROM sorlcur s2
    	WHERE
    		1=1
    		AND s1.sorlcur_pidm = s2.sorlcur_pidm
    		AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno
    		AND s2.sorlcur_cact_code = 'ACTIVE'
    		AND s2.sorlcur_current_cde = 'Y'
    		AND s2.sorlcur_lmod_code = 'LEARNER'
    )
    
    AND sorlcur_coll_code IN :EX_1_FACULTY_LIST
    		
);

/*
MERGE INTO GLBEXTR A USING (
*/
SELECT DISTINCT 'EXAM' c1 , 
:POPSEL_NAME c2 , 
:POPSEL_CREATOR c3 , 
:POPSEL_USER c4 , 
spriden_pidm c5 , 
sysdate c6 , 
'M' c7 
 FROM SPRIDEN t1 
 WHERE spriden_pidm IN 
		(
    SELECT DISTINCT shrmrks_pidm
FROM
    shrmrks
    JOIN shrgcom ON shrmrks_term_code = shrgcom_term_code AND shrmrks_crn = shrgcom_crn  AND shrmrks_gcom_id = shrgcom_id
    JOIN ssbsect ON shrmrks_crn = ssbsect_crn AND shrmrks_term_code = ssbsect_term_code
    JOIN sfrstcr ON shrmrks_term_code = sfrstcr_term_code AND shrmrks_crn = sfrstcr_crn AND shrmrks_pidm = sfrstcr_pidm
    JOIN stvrsts ON stvrsts_code = sfrstcr_rsts_code
    JOIN sorlcur s1 ON sfrstcr_pidm = s1.sorlcur_pidm AND sfrstcr_stsp_key_sequence = s1.sorlcur_key_seqno
WHERE
    1=1

    -- Only return module runs that meet these criteria
    AND shrmrks_crn IN (
        SELECT
            ssbsect_crn
        FROM
            ssbsect
            JOIN sobptrm ON ssbsect_term_code = sobptrm_term_code AND ssbsect_ptrm_code = sobptrm_ptrm_code
        WHERE
            1=1

            -- Limit to non-UMP modules

            AND ssbsect_subj_code||chr(1)||ssbsect_crse_numb NOT IN (
                SELECT gorsdav_pk_parenttab
                FROM gorsdav
                WHERE gorsdav_table_name = 'SCBCRKY' AND gorsdav_attr_name = 'UMP' AND sys.ANYDATA.accessvarchar2(gorsdav_value) = 'Y'
            )
            
            -- Limit to non-dissertation modules

            AND CONCAT(ssbsect_subj_code, ssbsect_crse_numb) IN (
                SELECT CONCAT(scrattr_subj_code, scrattr_crse_numb)
                FROM scrattr
                WHERE scrattr_attr_code != 'L7DS'
            )
            
            -- Limit to modules that end between specified dates
            AND sobptrm_end_date BETWEEN :EX_2_TAUGHT_MOD_START AND :EX_3_TAUGHT_MOD_END
        )

    -- Only include students who are still registered on the module
    AND stvrsts_incl_sect_enrl = 'Y'
    
    AND s1.sorlcur_cact_code = 'ACTIVE'
    AND s1.sorlcur_current_cde = 'Y'
    AND s1.sorlcur_lmod_code = 'LEARNER'
    AND s1.sorlcur_term_code = (
    	SELECT MAX(s2.sorlcur_term_code)
    	FROM sorlcur s2
    	WHERE
    		1=1
    		AND s1.sorlcur_pidm = s2.sorlcur_pidm
    		AND s1.sorlcur_key_seqno = s2.sorlcur_key_seqno
    		AND s2.sorlcur_cact_code = 'ACTIVE'
    		AND s2.sorlcur_current_cde = 'Y'
    		AND s2.sorlcur_lmod_code = 'LEARNER'
    )
    
    AND sorlcur_coll_code IN :EX_1_FACULTY_LIST
    		
)
/*
) B ON ( A.GLBEXTR_KEY= B.c5) WHEN NOT MATCHED THEN INSERT (A.GLBEXTR_APPLICATION
, A.GLBEXTR_SELECTION
, A.GLBEXTR_CREATOR_ID
, A.GLBEXTR_USER_ID
, A.GLBEXTR_KEY
, A.GLBEXTR_ACTIVITY_DATE
, A.GLBEXTR_SYS_IND) VALUES (B.c1
, B.c2
, B.c3
, B.c4
, B.c5
, B.c6
, B.c7)
WHEN MATCHED THEN UPDATE SET A.GLBEXTR_APPLICATION= B.c1
, A.GLBEXTR_SELECTION= B.c2
, A.GLBEXTR_CREATOR_ID= B.c3
, A.GLBEXTR_USER_ID= B.c4
, A.GLBEXTR_ACTIVITY_DATE= B.c6
, A.GLBEXTR_SYS_IND= B.c7;
*/
