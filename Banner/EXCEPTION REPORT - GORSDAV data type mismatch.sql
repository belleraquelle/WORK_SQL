SELECT
       gorsdav.*, sys.anydata.GetTypeName(gorsdav_value), 'SYS.' || GORSDAM_ATTR_DATA_TYPE
FROM
    gorsdav
    JOIN gorsdam ON gorsdav_table_name = gorsdam_table_name AND gorsdav_attr_name = gorsdam_attr_name
WHERE
    1=1
    AND sys.anydata.GetTypeName(gorsdav_value) != 'SYS.' || gorsdam_attr_data_type
;