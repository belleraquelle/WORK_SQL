select 
    s.username
    ,t.sid
    ,s.serial#
    ,sum(VALUE/100) as "CPU usage (seconds)"
from
    v$session s,
    v$sesstat t,
    v$statname n
where 1=1
    AND t.STATISTIC# = n.STATISTIC#
    AND NAME like '%CPU used by this session%'
    AND t.SID = s.SID
    AND s.status = 'ACTIVE'
    AND s.username is not null
GROUP BY s.username, t.sid, s.serial#
ORDER BY 4 DESC;

select SID, SERIAL#, USERNAME, STATUS, SCHEMANAME, SQL_FULLTEXT 
from 
    v$session sess,
    v$sql sql
Where 1=1
    AND sql.sql_id(+) = sess.sql_id
    AND sess.type = 'USER'
--    AND username like '%CDCADMIN%'
    AND sess.serial# = 47265
    AND SID = 7300
order by 1;

--ALTER SYSTEM KILL SESSION '3745,1696'; -- from SISCVT account (SID, SERIAL)


-- Check Privileges for specific user
SELECT * FROM DBA_SYS_PRIVS
WHERE GRANTEE = 'CDCADMIN';

SELECT * FROM DBA_ROLE_PRIVS
WHERE GRANTEE = 'CDCADMIN';

SELECT * FROM DBA_TAB_PRIVS
WHERE GRANTEE = 'CDCADMIN';