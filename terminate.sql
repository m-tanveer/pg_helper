


-- queries > 3 minutes
SELECT now()::date AS date,
    now()::time(0) AS time,
    pg_terminate_backend(pid),
    datname,
    pid,
    (now() - query_start)::time(0) AS runtime,
    EXTRACT(EPOCH FROM (now() - state_change))::INT AS runtime_secs,
    query_start::timestamp(0),
    usename,
    client_addr,
    client_port,
    state,
    query
FROM pg_stat_activity
WHERE state = 'idle'
AND now() - state_change > '5 MINUTES'::INTERVAL
ORDER BY (now() - state_change)::time(0) DESC;
