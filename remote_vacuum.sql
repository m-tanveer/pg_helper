-- vacuum/autovacuum queries
-- output log header
-- ts|pid|datname|runtime_secs|query_start|client_addr|client_port|state|waiting|query

SELECT '$HOST_NAME',
  now()::timestamp(0) AS ts,
  pid,
  datname,
  EXTRACT(EPOCH FROM (now() - query_start))::INT AS runtime_secs,
  query_start::timestamp(0),
  client_addr,
  client_port,
  state,
  waiting,
  query
FROM pg_stat_activity
WHERE query ilike 'autovacuum%'
OR query ilike 'vacuum%';
