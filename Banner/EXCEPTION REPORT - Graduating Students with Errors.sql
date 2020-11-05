/*

This query returns all UMP students with entries on the errors table
who have an expected completion date between the dates specified.

*/


SELECT DISTINCT
	CASE
		WHEN sorlcur_end_date BETWEEN '01-DEC-20' AND '31-DEC-20' THEN '202009'
		WHEN sorlcur_end_date BETWEEN '01-JAN-20' AND '30-JUN-21' THEN '202101'
	END AS "Graduating_In",
    sobcurr_coll_code AS "Faculty",
    obustrd_messages_pidm AS "PIDM",
    spriden_id AS "Student_Number",
    spriden_last_name AS "Last_Name",
    spriden_first_name AS "First_Name",
    obustrd_messages_program AS "Programme",
    sorlcur_end_date AS "Expected_Completion_Date",
    COUNT(obustrd_messages_ID) AS "Error_Count",
    ump_1 AS "UMP"
    
FROM
    obustrd_messages 
    JOIN spriden ON obustrd_messages_pidm = spriden_pidm AND spriden_change_ind is null
    JOIN sobcurr_add a1 ON obustrd_messages_program = sobcurr_program
    JOIN sorlcur a1 ON spriden_pidm = a1.sorlcur_pidm
    JOIN sgrstsp t1 ON a1.sorlcur_pidm = t1.sgrstsp_pidm AND a1.sorlcur_key_seqno = t1.sgrstsp_key_seqno
	JOIN sgbstdn t4 ON a1.sorlcur_pidm = t4.sgbstdn_pidm
	JOIN sfrensp ON a1.sorlcur_pidm = sfrensp_pidm AND a1.sorlcur_key_seqno = sfrensp_key_seqno

WHERE
    1=1
    
    -- Pick out maximum curriculum record
    AND a1.sorlcur_term_code = (
        SELECT MAX(t2.sorlcur_term_code)
        FROM sorlcur t2
        WHERE t2.sorlcur_pidm = a1.sorlcur_pidm AND t2.sorlcur_key_seqno = a1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER' AND t2.sorlcur_current_cde = 'Y' AND t2.sorlcur_cact_code = 'ACTIVE')
    AND a1.sorlcur_current_cde = 'Y'
    AND a1.sorlcur_cact_code = 'ACTIVE'
    AND a1.sorlcur_lmod_code = 'LEARNER'
    
    -- Current student status is Active
    AND t4.sgbstdn_term_code_eff = (
        SELECT MAX(e2.sgbstdn_term_code_eff)
        FROM sgbstdn e2
        WHERE t4.sgbstdn_pidm = e2.sgbstdn_pidm
    )
    AND sgbstdn_stst_code = 'AS'
    
    -- Current study path status is Active
    AND t1.sgrstsp_term_code_eff = (
        SELECT MAX(a2.sgrstsp_term_code_eff)
        FROM sgrstsp a2
        WHERE t1.sgrstsp_pidm = a2.sgrstsp_pidm AND t1.sgrstsp_key_seqno = a2.sgrstsp_key_seqno
    )
    AND t1.sgrstsp_stsp_code = 'AS'
    
    -- Student is enrolled for specified term
    AND sfrensp_term_code = '202009'
    AND sfrensp_ests_code = 'EN'
    
    -- Pick out true 'error' messages
    AND obustrd_messages_severity = 'E'
    
    -- Limit by faculty if applicable
    -- AND sobcurr_coll_code = 'TD'
    
    -- Expected completion date is between these two dates 
    AND a1.sorlcur_end_date BETWEEN '01-DEC-20' AND '30-JUN-21'
    
    -- Limit to students on UMP courses
    AND ump_1 = 'Y'
    
    
GROUP BY 
	sobcurr_coll_code,
    obustrd_messages_pidm,
    spriden_id,
    spriden_last_name,
    spriden_first_name,
    obustrd_messages_program,
    sorlcur_end_date,
    ump_1
    
ORDER BY
	"Graduating_In",
    obustrd_messages_program,
    spriden_last_name,
    spriden_first_name

;