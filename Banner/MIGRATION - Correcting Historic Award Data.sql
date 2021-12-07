UPDATE gorsdav
SET 
    gorsdav_value = GP_GOKSDIF.f_to_any('Bachelor of Science in Chiropractic'),
    gorsdav_activity_date = sysdate,
    gorsdav_user_id = 'BANSECR_SCLARKE'
WHERE gorsdav_pk_parenttab || gorsdav_table_name || gorsdav_attr_name IN (

SELECT 
    gorsdav_pk_parenttab || gorsdav_table_name || gorsdav_attr_name
FROM 
    spriden 
    JOIN shrdgmr ON spriden_pidm = shrdgmr_pidm 
    JOIN gorsdav ON gorsdav_pk_parenttab = shrdgmr_pidm||chr(1)||shrdgmr_seq_no
WHERE 
    1=1
    AND spriden_change_ind IS NULL
    AND gorsdav_table_name = 'SHRDGMR' 
    AND GORSDAV_ATTR_NAME = 'AWTITLEOLD'
    AND CAST(gorsdav_value AS VARCHAR(200)) = 'Bachelor of Science '
    --AND spriden_id = '01120288'
    AND spriden_id IN (
            '01120288',
            '99092337',
            '01110523',
            '01110613',
            '00070723',
            '99092409',
            '99092418',
            '99092436',
            '99092445',
            '99092454',
            '99092472',
            '99092490',
            '99092319',
            '99092328',
            '99092346',
            '99092355',
            '99092364',
            '99092373',
            '99092382',
            '99092391',
            '99125256',
            '99125265',
            '99125274',
            '99125283',
            '99125292',
            '99125319',
            '99125328',
            '99125337',
            '99125346',
            '99125355',
            '99125175',
            '99125571',
            '99125580',
            '99125247',
            '99125184',
            '99125110',
            '99125139',
            '99125148',
            '99125157',
            '99125166',
            '99125193',
            '99125200',
            '99125229',
            '99125238',
            '00069568',
            '00069577',
            '00069676',
            '00069847',
            '00069892',
            '00070093',
            '00070174',
            '00070246',
            '00070354',
            '00070363',
            '00070372',
            '00070390',
            '00070507',
            '00070534',
            '00070561',
            '00070599',
            '00070606',
            '00070615',
            '00070624',
            '99125634',
            '01110514',
            '01110532',
            '01110541',
            '01110550',
            '01110579',
            '01110588',
            '01110597',
            '01110604',
            '01110622',
            '01113121',
            '01110759',
            '01110768',
            '01110777',
            '01110786',
            '01110802',
            '01110811',
            '01110820',
            '01110876',
            '00070642',
            '00070705',
            '00070732',
            '00070797',
            '99125879',
            '99133392',
            '01110885',
            '01110894',
            '01110910',
            '01110948',
            '01110957',
            '01113013',
            '01113130',
            '01113159',
            '01113168',
            '01113177',
            '01113186',
            '01113195',
            '01113202',
            '01113220',
            '01113249',
            '99125888',
            '01123282',
            '01123309'
            )
        )
    ;
    
    SELECT * FROM shrdgmr;
    SELECT * FROM gorsdav WHERE gorsdav_table_name = 'SHRDGMR' AND GORSDAV_ATTR_NAME = 'AWTITLEOLD';
    SELECT spriden_pidm FROM spriden WHERE spriden_pidm = '6668342'