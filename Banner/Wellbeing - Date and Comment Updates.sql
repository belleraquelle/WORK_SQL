SELECT
    --serdtsr.*,
    serdtsr_pidm,
    serdtsr_term_code_eff,
    serdtsr_ssgp_code,
    serdtsr_sser_code,
    serdtsr_ssst_code,
    serdtsr_end_date,
    serdtsr_activity_date,
    sprmedi_comment
FROM
    serdtsr
    JOIN sprmedi ON serdtsr_pidm = sprmedi_pidm
WHERE
    serdtsr_end_date BETWEEN '14-MAY-2022' AND '16-MAY-2022'
    AND serdtsr_ssst_code IN ('AG','CM')
    AND sprmedi_comment LIKE '%temporary%2022%'
;

UPDATE serdtsr
SET
    serdtsr_end_date = '13-JUL-2022',
    serdtsr_activity_date = sysdate,
    serdtsr_user_id = 'BANSECR_SCLARKE'
WHERE
    serdtsr_end_date BETWEEN '09-JUL-2022' AND '11-JUL-2022'
    AND serdtsr_ssst_code IN ('AG','CM')
;

SELECT
    sprmedi_pidm,
    sprmedi_comment,
    substr(sprmedi_comment,0, instr(sprmedi_comment,'Friday')-1)||
    --'13.07.2022'||
    substr(sprmedi_comment,instr(sprmedi_comment,'Friday')+7,length(sprmedi_comment))
FROM
    sprmedi
WHERE
    sprmedi_comment LIKE '%2022%'
    AND sprmedi_comment NOT LIKE '%13.07.2022%'
    --AND sprmedi_comment LIKE '%Friday%'
;

UPDATE sprmedi
SET sprmedi_comment = substr(sprmedi_comment,0, instr(sprmedi_comment,'14.05.2022')-1)||
    '13.07.2022'||
    substr(sprmedi_comment,instr(sprmedi_comment,'14.05.2022')+10,length(sprmedi_comment))
WHERE sprmedi_comment LIKE '%14.05.2022%';

UPDATE sprmedi
SET sprmedi_comment = substr(sprmedi_comment,0, instr(sprmedi_comment,'Friday')-1)||
    --'13.07.2022'||
    substr(sprmedi_comment,instr(sprmedi_comment,'Friday')+7,length(sprmedi_comment))
WHERE sprmedi_comment LIKE '%13.07.2022%'
    AND sprmedi_comment LIKE '%Friday%'
