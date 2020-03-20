SELECT
	a.gorsdav_pk_parenttab AS "SobcurrRule", 
	a.gorsdav_value.accessVARCHAR2() AS "StaffNumber"
FROM
	GORSDAV a
WHERE
	1=1
	AND a.gorsdav_table_name = 'SOBCURR'
	AND a.gorsdav_attr_name = 'SUBJ_COORD'
	AND a.gorsdav_value.accessVARCHAR2() = 'p0019917'
	AND a.gorsdav_pk_parenttab IN
		(SELECT
			b.gorsdav_pk_parenttab
		FROM 
			gorsdav b
		WHERE
			1=1
			AND b.gorsdav_table_name = 'SOBCURR'
			AND b.gorsdav_attr_name = 'VALSTATUS'
			AND b.gorsdav_value.accessVARCHAR2() = 'CA')
;