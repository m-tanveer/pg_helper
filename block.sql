SELECT
   now()::timestamp,
   -- blocked processes
   blocked_locks.pid AS blocked_pid,
   now() - blocked_activity.query_start as blocked_duration,
   blocked_locks.locktype as blocked_locktype,
   blocked_locks.relation::regclass as blocked_relation,
   blocked_locks.mode as blocked_mode,
   blocked_locks.page as blocked_page,
   blocked_locks.tuple as blocked_tuple,
   blocked_locks.classid::regclass ,
   blocked_locks.objid,
   blocked_locks.virtualxid,
   blocked_locks.transactionid,
   blocked_locks.virtualtransaction,
   blocked_locks.granted,
   -- blocking processes
   blocking_locks.pid AS blocking_pid,
   now() - blocking_activity.query_start as blocking_duration,
   blocking_locks.locktype as blocking_locktype,
   blocking_locks.relation::regclass as blocking_relation,
   blocking_locks.mode as blocking_mode,
   blocking_locks.page as blocking_page,
   blocking_locks.tuple as blocking_tuple ,
   blocked_locks.classid::regclass ,
   blocking_locks.objid,
   blocking_locks.virtualxid,
   blocking_locks.transactionid,
   blocking_locks.virtualtransaction,
   blocking_locks.granted
FROM
   pg_catalog.pg_locks blocked_locks
   JOIN
      pg_catalog.pg_stat_activity blocked_activity
      ON blocked_activity.pid = blocked_locks.pid
   JOIN
      pg_catalog.pg_locks blocking_locks
      ON blocking_locks.locktype = blocked_locks.locktype
      AND blocking_locks.DATABASE IS NOT DISTINCT
FROM
   blocked_locks.DATABASE
   AND blocking_locks.relation IS NOT DISTINCT
FROM
   blocked_locks.relation
   AND blocking_locks.page IS NOT DISTINCT
FROM
   blocked_locks.page
   AND blocking_locks.tuple IS NOT DISTINCT
FROM
   blocked_locks.tuple
   AND blocking_locks.virtualxid IS NOT DISTINCT
FROM
   blocked_locks.virtualxid
   AND blocking_locks.transactionid IS NOT DISTINCT
FROM
   blocked_locks.transactionid
   AND blocking_locks.classid IS NOT DISTINCT
FROM
   blocked_locks.classid
   AND blocking_locks.objid IS NOT DISTINCT
FROM
   blocked_locks.objid
   AND blocking_locks.objsubid IS NOT DISTINCT
FROM
   blocked_locks.objsubid
   AND blocking_locks.pid != blocked_locks.pid
   JOIN
      pg_catalog.pg_stat_activity blocking_activity
      ON blocking_activity.pid = blocking_locks.pid
WHERE
   NOT blocked_locks.GRANTED
order by
   blocking_locks.pid LIMIT 10 ;


-- https://raw.githubusercontent.com/awslabs/rds-support-tools/master/postgres/diag/sql/list-sessions-blocking-others.sql
SELECT blocked_locks.pid     AS blocked_pid,
    blocked_activity.usename  AS blocked_user,
    blocking_locks.pid     AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query    AS blocked_statement,
    blocking_activity.query   AS current_statement_in_blocking_process
FROM  pg_catalog.pg_locks         blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks         blocking_locks
   ON blocking_locks.locktype = blocked_locks.locktype
   AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
   AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
   AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
   AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
   AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
   AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
   AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
   AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
   AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
   AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.GRANTED;
