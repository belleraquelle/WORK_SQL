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
 