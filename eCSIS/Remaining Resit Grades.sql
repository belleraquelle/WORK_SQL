SELECT
    ui.unit_code, u.full_title, u.level_code, u.dissertation, ui.end_date,
    reg.student_number, mge.grade
FROM
    student_unit_selections sus
    JOIN mark_grade_equivalents mge ON sus.mge_id = mge.mge_id
    JOIN unit_instances ui ON sus.unin_id = ui.unin_id
    JOIN units u ON ui.unit_code = u.code
    JOIN registrations reg on sus.regn_id = reg.regn_id
WHERE
    1=1
    AND grade IN ('RC', 'RE', 'RB', 'DC', 'DE', 'DB', 'ZE', 'ZB', 'ZC')
    AND ui.end_date > '01-MAY-19'
    AND u.level_code = '7'
ORDER BY
    ui.end_date,
    ui.unit_code
;