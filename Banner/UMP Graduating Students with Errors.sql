/*

This query returns all UMP students with entries on the errors table
who have an expected completion date between the dates specified.

*/


SELECT DISTINCT
    sobcurr_coll_code AS "Faculty",
    obustrd_messages_pidm AS "PIDM",
    spriden_id AS "Student_Number",
    spriden_last_name AS "Last_Name",
    spriden_first_name AS "First_Name",
    obustrd_messages_atts_code AS "Stage",
    obustrd_messages_program AS "Programme",
    sorlcur_end_date AS "Expected_Completion_Date",
    obustrd_messages_id AS "Error_Message_ID",
    obustrd_messages_params AS "Error_Parameters",
    ump_1 AS "UMP"
    
FROM
    obustrd_messages 
    JOIN spriden ON obustrd_messages_pidm = spriden_pidm
    JOIN sobcurr_add a1 ON obustrd_messages_program = sobcurr_program
    JOIN sorlcur t1 ON spriden_pidm = sorlcur_pidm

WHERE
    1=1
    AND obustrd_messages_severity = 'E'
    -- Limit by faculty if applicable
    -- AND sobcurr_coll_code = 'TD'
    
    -- Limit to current student number
    AND spriden_change_ind is null
    
    -- Pick out maximum curriculum record
    AND t1.sorlcur_term_code = (
        SELECT MAX(t2.sorlcur_term_code)
        FROM sorlcur t2
        WHERE t2.sorlcur_pidm = t1.sorlcur_pidm AND t2.sorlcur_key_seqno = t1.sorlcur_key_seqno AND t2.sorlcur_lmod_code = 'LEARNER')
    AND t1.sorlcur_current_cde = 'Y'
    AND t1.sorlcur_cact_code = 'ACTIVE'
    AND t1.sorlcur_lmod_code = 'LEARNER'
    
    -- Expected completion date is between these two dates 
    AND t1.sorlcur_end_date BETWEEN '01-FEB-20' AND '30-JUN-20'
    
    -- Limit to students on UMP courses
    AND ump_1 = 'Y'
    
ORDER BY
    obustrd_messages_program,
    spriden_last_name,
    spriden_first_name

;