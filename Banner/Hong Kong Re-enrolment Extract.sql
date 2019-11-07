/*

This query extracts the personal details of the Hong Kong students who are due to re-enrol so that it can
be checked, updated and their continued enrolment confirmed.

*/


SELECT
    --sgbstdn_stst_code AS "Student_Status",
    --sgrstsp_key_seqno,
    --sgrstsp_stsp_code,
    spriden_id AS "Student_Number",
    spriden_last_name AS "Surname",
    spriden_first_name AS "First_Name",
    spriden_mi AS "Middle_Names",
    spbpers_sex AS "Gender",
    spbpers_birth_date AS "Date_Of_Birth",
    -- "Disability (if appropriate)"  -- Students can have multiple in Banner
    gobintl_natn_code_legal AS "Nationality",
    stvethn_desc AS "Ethnic_Origin",
    -- "Permanently_Resident_In"
    sorlcur_program AS "Course_Of_Study",
    smrprle_program_desc AS "Course_Description",
    sorlcur_camp_code AS "Campus",
    sorlcur_styp_code AS "Mode_of_attendance",
    sgrsatt_atts_code AS "Current_Stage",
    sorlcur_end_date AS "Expected_Completion_Date",
    home_address.spraddr_street_line1 AS "Home_Address_Line_1",
    home_address.spraddr_street_line2 AS "Home_Address_Line_2",
    home_address.spraddr_street_line3 AS "Home_Address_Line_3",
    home_address.spraddr_city AS "Home_Address_City",
    home_address.spraddr_zip AS "Home_Address_Postcode",
    home_nation.stvnatn_nation AS "Home_Address_Country",
    mobile_tel.sprtele_intl_access AS "Mobile_Telephone_Number",
    home_tel.sprtele_intl_access AS "Home_Telephone_Number",
    email.goremal_email_address AS "Personal_Email_Address"
    
    
FROM

    spriden
    JOIN spbpers ON spriden_pidm = spbpers_pidm
    JOIN gobintl ON spriden_pidm = gobintl_pidm
        JOIN stvethn ON spbpers_ethn_code = stvethn_code
    JOIN sorlcur ON spriden_pidm = sorlcur_pidm AND sorlcur_lmod_code = 'LEARNER' AND sorlcur_term_code_end IS NULL
        JOIN smrprle ON sorlcur_program = smrprle_program
    JOIN sgbstdn t1 ON spriden_pidm = sgbstdn_pidm 
        AND t1.sgbstdn_term_code_eff = (
            SELECT MAX(t2.sgbstdn_term_code_eff)
            FROM sgbstdn t2
            WHERE t2.sgbstdn_pidm = t1.sgbstdn_pidm
            )
    JOIN sgrsatt s1 ON sorlcur_pidm = s1.sgrsatt_pidm AND sorlcur_key_seqno = s1.sgrsatt_stsp_key_sequence
        AND s1.sgrsatt_term_code_eff = (
            SELECT MAX(s2.sgrsatt_term_code_eff)
            FROM sgrsatt s2
            WHERE 
                1=1
                AND s2.sgrsatt_pidm = s1.sgrsatt_pidm 
                AND s2.sgrsatt_stsp_key_sequence = s1.sgrsatt_stsp_key_sequence
                AND s2.sgrsatt_term_code_eff <= 
                    (SELECT stvterm_code FROM stvterm WHERE SYSDATE BETWEEN stvterm_start_date AND stvterm_end_date)
            )  
    JOIN sgrstsp p1 ON sorlcur_pidm = p1.sgrstsp_pidm AND sorlcur_key_seqno = p1.sgrstsp_key_seqno
        AND p1.sgrstsp_term_code_eff = (
            SELECT MAX(p2.sgrstsp_term_code_eff)
            FROM sgrstsp p2
            WHERE
            p2.sgrstsp_pidm = p1.sgrstsp_pidm AND p2.sgrstsp_key_seqno = p1.sgrstsp_key_seqno
            )
    JOIN spraddr home_address ON spriden_pidm = home_address.spraddr_pidm 
        AND spraddr_to_date IS NULL AND spraddr_status_ind IS NULL AND spraddr_atyp_code = 'HO'
        JOIN stvnatn home_nation ON home_address.spraddr_natn_code = home_nation.stvnatn_code
        
    LEFT JOIN sprtele mobile_tel ON spriden_pidm = mobile_tel.sprtele_pidm AND mobile_tel.sprtele_tele_code = 'MO'
    LEFT JOIN sprtele home_tel ON spriden_pidm = home_tel.sprtele_pidm AND home_tel.sprtele_tele_code = 'HO'
    LEFT JOIN goremal email ON spriden_pidm = email.goremal_pidm 
        AND email.goremal_status_ind = 'A' AND goremal_preferred_ind = 'Y' AND email.goremal_emal_code = 'PERS'
    
    -- 944 
WHERE
    1=1
    
    -- Only include current student number
    AND spriden_change_ind IS NULL
    
    -- Only include current students and study paths
    AND sgbstdn_stst_code = 'AS'
    AND sgrstsp_stsp_code= 'AS'
    
    -- Restrict to students with AIE campus
    AND sorlcur_camp_code = 'AIE'
    
    -- Uncomment the below to only include students with a completion date beyond today
    --AND sorlcur_end_date >= sysdate
    
    /*
    Change the term entered here to control who is pulled through on the report. 
    Anyone who doesn't have one of these statuses for the term is included.
    */
    
    AND sgrstsp_pidm NOT IN (
        SELECT sfrensp_pidm FROM sfrensp WHERE sfrensp_term_code = '202001' AND sfrensp_ests_code in ('AT', 'EN', 'UT', 'WD') 
    )
    
    -- Exclude students whose term of entry is the term specified below
    AND sorlcur_term_code_admit != '202001'
;