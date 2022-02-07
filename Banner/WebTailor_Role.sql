-- create a new WebTailor Role
Insert into WTAILOR.TWTVROLE 
(TWTVROLE_CODE,
 TWTVROLE_DESC,
 TWTVROLE_ACTIVITY_DATE,
 TWTVROLE_USER_DEFINED_IND,
 TWTVROLE_USER_ID,
 TWTVROLE_DATA_ORIGIN) 
values 
('ADMIN_UPLOAD',
 'Admissions Upload Role',
 SYSDATE,
 'Y',
 USER,
 'ENHC0010457');

-- assign a person to that role by pidm (can also be done in WebTailor 
-- application on 'User Roles' page.
Insert into WTAILOR.TWGRROLE
(TWGRROLE_PIDM,
 TWGRROLE_ROLE,
 TWGRROLE_ACTIVITY_DATE)
values
(1621452,  -- for me
 'ADMIN_UPLOAD',
 SYSDATE);
 
 -- Check using P number
 SELECT 'Y' AS "Has_Role"
 FROM wtailor.twgrrole
 WHERE 
    twgrrole_pidm = (SELECT spriden_pidm FROM spriden WHERE spriden_id = :spriden_id) 
    AND twgrrole_role = 'PREENROLADMIN'
;
 
 --Insert using P numbers
 Insert into WTAILOR.TWGRROLE
(TWGRROLE_PIDM,
 TWGRROLE_ROLE,
 TWGRROLE_ACTIVITY_DATE)
values
((SELECT spriden_pidm FROM spriden WHERE spriden_id = :spriden_id),  -- for me
 'PREENROLADMIN',
 SYSDATE);
 
 -- Return all columns using staff number
SELECT * 
 FROM wtailor.twgrrole
 WHERE 
    twgrrole_pidm = (SELECT DISTINCT spriden_pidm FROM spriden WHERE spriden_id = :spriden_id) 
    AND twgrrole_role = 'PREENROLADMIN'
;

-- Delete using PIDM and role
DELETE FROM wtailor.twgrrole WHERE twgrrole_pidm = :pidm AND twgrrole_role = 'PREENROLADMIN';