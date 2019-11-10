SELECT DISTINCT
    sobcurr_coll_code,
    obustrd_messages_pidm,
    spriden_id,
    spriden_last_name,
    spriden_first_name,
    obustrd_messages_atts_code,
    obustrd_messages_program,
    obustrd_messages_id,
    obustrd_messages_params
    
FROM
    obustrd_messages 
    JOIN spriden ON obustrd_messages_pidm = spriden_pidm
    JOIN sobcurr ON obustrd_messages_program = sobcurr_program

WHERE
    1=1
    AND obustrd_messages_severity = 'E'
    AND sobcurr_coll_code = 'TD'
    AND spriden_change_ind is null
    
ORDER BY
    obustrd_messages_program,
    spriden_last_name,
    spriden_first_name

;