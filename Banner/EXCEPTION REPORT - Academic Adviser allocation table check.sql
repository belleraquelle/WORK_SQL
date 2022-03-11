/*
 This query identifies issues with the data held in the ACADEMIC_ADVISERS table that is used
 in the process that auto-allocates new students to their academic advisor.

 It will identify:
    - IDs in the table that don't have a corresponding P number attached to their PIDM so aren't members of staff
    - Where the member of staff isn't flagged as an adviser in SIAINST

 Created - 11/03/2022 SRC
 */


SELECT DISTINCT
    aa_staff_id AS Banner_ID,
    aa_surname ||', ' || aa_forenames AS advisor_name,
    sibinst_advr_ind AS advisor_flag,
    CASE
        WHEN (spriden_pidm NOT IN (SELECT spriden_pidm FROM spriden WHERE spriden_id LIKE 'P%'))
            THEN 'Y'
    END AS Not_Staff
FROM
     academic_advisers
    JOIN spriden ON aa_staff_id = spriden_id
    LEFT JOIN sibinst s1 ON spriden_pidm = sibinst_pidm
WHERE
    -- Pick out max sibinst record
    s1.sibinst_term_code_eff = (
        SELECT MAX(s2.sibinst_term_code_eff)
        FROM sibinst s2
        WHERE s1.sibinst_pidm = s2.sibinst_pidm
        )
    -- Limit to records that are either missing the adivosr flag in SIAINST or aren't a member of staff
    AND (spriden_pidm NOT IN (SELECT spriden_pidm FROM spriden WHERE spriden_id LIKE 'P%')
        OR (sibinst_advr_ind IS NULL OR sibinst_advr_ind = 'N'))
;
