-- locking queries 
SELECT pid,
       usename,
       pg_blocking_pids(pid) AS blocked_by,
       QUERY AS blocked_query
FROM pg_stat_activity
WHERE cardinality(pg_blocking_pids(pid)) > 0;
