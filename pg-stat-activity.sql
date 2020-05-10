-- while [ 1 = 1 ];do psql -h localhost -F',' -A -f /backups/dbscripts/pgstatactivity-snap.sql >> /tmp/pgstatactivity-$(echo $(hostname) | cut -d'.' -f1 | cut -d'-' -f1)-$(date +%Y-%m-%d-%H).csv; echo "pid:$$"; sleep 20; done &

-- queries > 3 minutes
SELECT now()::date AS date,
    now()::time(0) AS time,
    datname,
    pid,
    (now() - query_start)::time(0) AS runtime,
    EXTRACT(EPOCH FROM (now() - query_start))::INT AS runtime_secs,
    EXTRACT(EPOCH FROM (now() - query_start))*1000::INT AS runtime_millisecs,
    query_start::timestamp(0),
    usename,
    client_addr,
    client_port,
    state,
    regexp_replace(query,'[\s\u2028]+', ' ', 'g') AS query
FROM pg_stat_activity
WHERE state <> 'idle'
-- AND now() - query_start > '3 MINUTES'::INTERVAL
AND now() - query_start > '30 MILLISECONDS'::INTERVAL
-- ORDER BY EXTRACT(EPOCH FROM (now() - query_start))::INT DESC;
ORDER BY (now() - query_start)::time(0) DESC;

-- query stat by pid
SELECT now() AS ts,
  datname,
  pid,
  now() - query_start AS runtime,
  EXTRACT(EPOCH FROM (now() - query_start))::INT AS runtime_secs,
  query_start,
  usename,
  client_addr,
  client_port,
  state,
  waiting,
  regexp_replace(query,'[\s\u2028]+', ' ', 'g') AS query
FROM pg_stat_activity
WHERE pid = '21195'
ORDER BY runtime_secs DESC ;

--  count by client connection
SELECT datname,
  client_addr,
  count(*)
FROM pg_stat_activity
WHERE
client_addr IS NOT NULL -- ignore autovacuum jobs
GROUP BY 1,2
ORDER BY 3 DESC ;

--  count by state
SELECT datname,
  state,
  count(*)
FROM pg_stat_activity
WHERE state IS NOT NULL
GROUP BY 1,2
ORDER BY 3 DESC ;

--  count by client connection, state
SELECT datname,
  client_addr,
  state,
  count(*)
FROM pg_stat_activity
WHERE client_addr IS NOT NULL -- ignore autovacuum jobs
GROUP BY 1,2,3
ORDER BY 4 DESC ;

--  count by client connection, state, user
SELECT datname,
  usename,
  client_addr,
  state,
  count(*)
FROM pg_stat_activity
-- WHERE client_addr IS NOT NULL -- ignore autovacuum jobs
GROUP BY 1,2,3,4
ORDER BY 5 DESC ;

-- autovacuum query
SELECT now()::date AS date,
  now()::time(0) AS time,
  pid,
  datname,
  (now() - query_start)::time(0) as runtime,
  query_start::timestamp(0),
  client_addr,
  client_port,
  state,
  waiting,
  regexp_replace(query,'[\s\u2028]+', ' ', 'g') AS query
FROM pg_stat_activity
WHERE query ilike 'autovacuum%'
ORDER BY EXTRACT(EPOCH FROM (now() - query_start))::INT DESC;


-- autovacuum query
SELECT now()::date AS date,
  now()::time(0) AS time,
  pid,
  datname,
  (now() - query_start)::time(0) as runtime,
  query_start::timestamp(0),
  state,
  query
FROM pg_stat_activity
WHERE query ilike 'autovacuum%'
ORDER BY EXTRACT(EPOCH FROM (now() - query_start))::INT DESC;


-- vacuum query
SELECT now()::date AS date,
  now()::time(0) AS time,
  pid,
  datname,
  (now() - query_start)::time(0) as runtime,
  query_start::timestamp(0),
  client_addr,
  client_port,
  state,
  waiting,
  regexp_replace(query,'[\s\u2028]+', ' ', 'g') AS query
FROM pg_stat_activity
WHERE query ilike 'vacuum%'
ORDER BY EXTRACT(EPOCH FROM (now() - query_start))::INT DESC;

-- check repack activity
SELECT now()::date AS date,
  now()::time(0) AS time,
  pid,
  datname,
  -- EXTRACT(EPOCH FROM (now() - query_start))::INT AS runtime_secs,
  (now() - query_start)::time(0) as runtime,
  query_start::timestamp(0),
  client_addr,
  client_port,
  state,
  waiting,
  regexp_replace(query,'[\s\u2028]+', ' ', 'g') AS query
FROM pg_stat_activity
WHERE query ilike 'LOCK TABLE%'
ORDER BY EXTRACT(EPOCH FROM (now() - query_start))::INT DESC;

-- size of the cluster
SELECT sum(pg_database_size(d.datname)) AS db_size_bytes,
  pg_size_pretty(sum(pg_database_size(d.datname))) AS db_size_pretty
FROM pg_database d
GROUP BY d.datdba;


select pid, datname , query_start, xact_start
, pg_cancel_backend(pid) as action
from pg_stat_activity where state <> 'idle'
and pid <> pg_backend_pid()
and now() - query_start > '0.1 seconds'::INTERVAL


select pid, pg_terminate_backend(pid) as termination_state
from pg_stat_activity
where state='idle'
and now() - query_start > '180 SECOND'::INTERVAL
and pid <> pg_backend_pid();
