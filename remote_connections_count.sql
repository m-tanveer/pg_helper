--  count by client connections active
SELECT '${HOST_NAME}',
  client_addr,
  datname,
  count(*)
FROM pg_stat_activity
WHERE state <> 'active'
AND client_addr IS NOT NULL -- ignore autovacuum jobs
GROUP BY 2,3
ORDER BY 4 DESC ;
