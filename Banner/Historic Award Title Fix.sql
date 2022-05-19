SELECT 
    gorsdav_pk_parenttab, 
    substr(gorsdav_pk_parenttab,0,7),
    SYS.ANYDATA.accessVarchar2(gorsdav_value),
    gorsdav.*
FROM 
    gorsdav 


--; 
--UPDATE gorsdav SET gorsdav_value = SYS.ANYDATA.convertVarchar2('Bachelor of Arts in Business Studies')

WHERE
    1=1
    AND gorsdav_table_name = 'SHRDGMR' 
    AND gorsdav_attr_name = 'AWTITLEOLD'
    AND gorsdav_pk_parenttab = '14253771'
    AND SYS.ANYDATA.accessVarchar2(gorsdav_value) = 'Bachelor of Arts '
    AND SUBSTR(gorsdav_pk_parenttab,0,7) IN (
        SELECT DISTINCT spriden_pidm
        FROM spriden
        WHERE spriden_id IN (
'82673',
'82844',
'82880',
'65320',
'82637',
'1281916',
'70822',
'2130136',
'2160444',
'1281835',
'2139815',
'1281925',
'2161460',
'2163548',
'2165904',
'2176856',
'2178177',
'2137981',
'2139392',
'2139725',
'2139752',
'2139799',
'2139806',
'1281844'
        )
    )
    ;

SELECT * FROM gorsdav WHERE gorsdav_table_name = 'SHRDGMR' AND gorsdav_attr_name = 'AWTITLEOLD';


SELECT * FROM SHRDGMR_add;

SELECT spriden_pidm  from spriden where spriden_id = '87200919';

SELECT * FROM ;
              UPDATE shrdgmr_add SET awtitleold_1 = 'Bachelor of Arts in Planning Studies'
               WHERE shrdgmr_pidm = '1454006' AND SHRDGMR_GRAD_DATE = '06-JUL-1990' AND awtitleold_1 = 'Bachelor of Arts ';