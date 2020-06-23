SELECT DISTINCT
    spriden_id AS "Student_Number",
    spriden_first_name ||' ' || spriden_last_name AS "Student_Name",
    CASE 
    	WHEN
    		spriden_pidm IN ( 
    		
    			SELECT s1.shrtckg_pidm
    			FROM shrtckg s1
    			WHERE
    				s1.shrtckg_seq_no = (SELECT MAX(s2.shrtckg_seq_no) FROM shrtckg s2 WHERE s2.shrtckg_pidm = s1.shrtckg_pidm AND s2.shrtckg_term_code = s1.shrtckg_term_code AND s2.shrtckg_tckn_seq_no = s1.shrtckg_tckn_seq_no)
					AND s1.shrtckg_grde_code_final = 'DD'
 
    		)	
		THEN 'Y'
		ELSE NULL
		END AS "DD_Grade",
    shrapsp_astd_code_end_of_term AS "Academic_Standing",
    :popsel_name AS "Popsel"

FROM
    spriden 
    LEFT JOIN shrapsp ON spriden_pidm = shrapsp_pidm AND shrapsp_term_code = '202001'
    
WHERE 
    1=1
    
    AND spriden_change_ind IS NULL

    
    -- Limit to students in specified popsel
    AND spriden_pidm in (SELECT glbextr_key FROM glbextr WHERE glbextr_selection = :popsel_name)
    
    AND ((
    
    	spriden_pidm IN ( 
    		
    			SELECT s1.shrtckg_pidm
    			FROM shrtckg s1
    			WHERE
    				s1.shrtckg_seq_no = (SELECT MAX(s2.shrtckg_seq_no) FROM shrtckg s2 WHERE s2.shrtckg_pidm = s1.shrtckg_pidm AND s2.shrtckg_term_code = s1.shrtckg_term_code AND s2.shrtckg_tckn_seq_no = s1.shrtckg_tckn_seq_no)
					AND s1.shrtckg_grde_code_final = 'DD')
    	
    	AND shrapsp_astd_code_end_of_term != 'D2'
    )
    
    OR 
    
    (
    
    	spriden_pidm NOT IN ( 
    		
    			SELECT s1.shrtckg_pidm
    			FROM shrtckg s1
    			WHERE
    				s1.shrtckg_seq_no = (SELECT MAX(s2.shrtckg_seq_no) FROM shrtckg s2 WHERE s2.shrtckg_pidm = s1.shrtckg_pidm AND s2.shrtckg_term_code = s1.shrtckg_term_code AND s2.shrtckg_tckn_seq_no = s1.shrtckg_tckn_seq_no)
					AND s1.shrtckg_grde_code_final = 'DD')
    	
    	AND shrapsp_astd_code_end_of_term = 'D2'
    ))
    

ORDER BY 
    spriden_first_name ||' ' || spriden_last_name
;