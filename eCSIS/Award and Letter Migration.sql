
--Letters
SELECT
    reg.student_number,
    reg.crse_code,
    people.surname || ', ' || people.forenames,
    letters.*
FROM
    regn_alps letters
    JOIN registrations reg ON letters.regn_id = reg.regn_id
    JOIN people ON reg.per_id_student = people.per_id
WHERE
    letter_date BETWEEN '01-DEC-19' AND '11-DEC-19'
ORDER BY
    crse_code, 
    people.surname || ', ' || people.forenames
;

-- Awards
SELECT
    reg.student_number,
    people.surname || ', ' || people.forenames,
    aType.code,
    aType.short_title,
    aType.full_title,
    ac.division, 
    ac.title,
    sa.*
FROM
    student_awards sa
    JOIN registrations reg ON sa.regn_id = reg.regn_id
    JOIN people ON reg.per_id_student = people.per_id
    JOIN course_awards ca ON sa.cawd_id = ca.cawd_id
    JOIN award_types aType ON ca.awdt_code = aType.code
    LEFT JOIN award_classes ac ON sa.awcl_id = ac.awcl_id
WHERE
    date_awarded BETWEEN '01-DEC-19' AND '11-DEC-19'
;