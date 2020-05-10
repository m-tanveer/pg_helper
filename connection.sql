--
-- Author : Mohamed Tanveer (mohamedt@zeta.tech)
--

-- identify the connection count
SELECT datname, usename, count(*) FROM pg_stat_activity GROUP BY 1,2 ORDER BY 3 DESC  LIMIT 10;
SELECT usename, count(*) FROM pg_stat_activity GROUP BY 1 ORDER BY 2 DESC LIMIT 10 ;
SELECT datname, count(*) FROM pg_stat_activity GROUP BY 1 ORDER BY 2 DESC  LIMIT 10;

-- queries running longer than 3 minutes
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
WHERE now() - query_start > '3 MINUTES'::INTERVAL
ORDER BY (now() - query_start)::time(0) DESC;

--  terminate the long running (> 3mins)
SELECT  pg_terminate_backend(pid)
FROM pg_stat_activity 
WHERE now() - query_start > '3 MINUTES'::INTERVAL
ORDER BY (now() - query_start)::time(0) DESC;

-- to set connection limit to a database
ALTER DATABASE ledger CONNECTION LIMIT 30 ;

-- to reset the connection limit set on a database
ALTER DATABASE ledger CONNECTION LIMIT -1 ;

--  to check the connection limit at a database level
SELECT datname, datconnlimit FROM pg_database where datconnlimit <> -1 ;

-- to set connection limit at a user level
ALTER USER mohamedt CONNECTION LIMIT 10 ;

-- to reset the connection limit set on a user
ALTER USER mohamedt CONNECTION LIMIT -1 ;

-- to check connection limit at a user level
SELECT rolname, rolconnlimit FROM pg_roles where rolconnlimit not '-1' ;
