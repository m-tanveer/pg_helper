-- long running queries > 3 mins
-- output log header
-- ts|pid|datname|runtime_secs|query_start|user|client_addr|client_port|state|waiting|query
SELECT '$HOST_NAME',
  now()::timestamp(0) AS ts,
  pid,
  datname,
  EXTRACT(EPOCH FROM (now() - query_start))::INT AS runtime_secs,
  query_start::timestamp(0),
  usename,
  client_addr,
  client_port,
  state,
  waiting,
  regexp_replace(query,'[\s\u2028]+', ' ', 'g') AS query
FROM pg_stat_activity
WHERE state <> 'idle'
AND now() - query_start > '3 MINUTES'::INTERVAL
ORDER BY runtime_secs DESC ;
