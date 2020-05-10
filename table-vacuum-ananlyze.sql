-- priority 1 tables
WITH p1_tables as(
  SELECT c.oid,
    nspname||'.'||c.relname as table,
    -- below commented columns are only for sql behaviour analysis
    -- concat(substring(substring(c.relname FROM length(c.relname) - 6 ) from 0 for 5),'-', substring(c.relname, '..$'), '-01') as table_date
    -- substring(substring(c.relname FROM length(c.relname) - 6 ) from 0 for 5) as table_year,
    -- substring(c.relname, '..$') as table_month,
  	COALESCE(NULLIF(pg_size_pretty(pg_table_size(c.oid)),''),'0') as size_pretty, -- size in human readable
    COALESCE(pg_table_size(c.oid),'0') AS size, -- size in bytes
  	c.reltuples,
    ut.n_dead_tup as dead_rows,
    -- if last vacuum/autovacuum record null , manipulate 24 hour old timestamp
    CASE WHEN ut.last_vacuum IS NULL THEN now() - interval '24 hour' ELSE ut.last_vacuum END AS last_vacuum,
    CASE WHEN ut.last_autovacuum IS NULL THEN now() - interval '24 hour' ELSE ut.last_autovacuum END AS last_autovacuum,
    -- if last analyze/autoanalyze record null , manipulate 24 hour old timestamp
    CASE WHEN last_analyze IS NULL THEN now() - interval '24 hour' ELSE last_analyze END AS last_analyze,
    CASE WHEN last_autoanalyze IS NULL THEN now() - interval '24 hour' ELSE last_autoanalyze END AS last_autoanalyze
  FROM pg_namespace ns
  JOIN pg_class c ON c.relnamespace=ns.oid
  JOIN pg_stat_user_tables ut ON ut.relid=c.oid
  WHERE  ns.nspname IN ('ods','dw')
  -- current year and previous year partition tables only to handle begining and end of year
  AND c.relname LIKE  '%p'||date_part('year', now()::date)||'%' OR c.relname LIKE  '%p'||date_part('year', now()::date) - 1||'%'
  AND c.relkind='r'
  -- filter tables with 0 estimated rows
  AND c.reltuples <> 0
  -- consider only current and 2 months old partitions for vacuum
  -- ..$ - last 2 digits(month)
  AND date_part('month', age(now()::date, concat(substring(substring(c.relname FROM length(c.relname) - 6 ) from 0 for 5),'-', substring(c.relname, '..$'), '-01')::date)) <= 2
),
-- priority 2 tables
p2_tables as (
  SELECT c.oid,
    nspname||'.'||c.relname as tablename,
    REPLACE(pg_size_pretty(pg_relation_size(c.oid)),' ','') as size,
    c.reltuples,
    ut.n_dead_tup as dead_rows,
    -- if last vacuum/autovacuum record null , manipulate 24 hour old timestamp
    CASE WHEN last_vacuum IS NULL THEN now() - interval '24 hour' ELSE last_vacuum END AS last_vacuum,
    CASE WHEN last_autovacuum IS NULL THEN now() - interval '24 hour' ELSE last_autovacuum END AS last_autovacuum,
    -- if last analyze/autoanalyze record null , manipulate 24 hour old timestamp
    CASE WHEN last_analyze IS NULL THEN now() - interval '24 hour' ELSE last_analyze END AS last_analyze,
    CASE WHEN last_autoanalyze IS NULL THEN now() - interval '24 hour' ELSE last_autoanalyze END AS last_autoanalyze
  FROM pg_namespace ns
  JOIN pg_class c ON c.relnamespace=ns.oid
  JOIN pg_stat_user_tables ut ON ut.relid=c.oid
  WHERE ns.nspname IN ('ods','dw')
  AND c.relkind='r'
  -- filter for row estimates
  AND c.reltuples <> 0
),
-- snap stats
stats_snap as (
  SELECT sut2.relid,
  (sut2.n_tup_upd - sut1.n_tup_upd) +
  (sut2.n_tup_del - sut1.n_tup_del) +
  (sut2.n_tup_hot_upd - sut1.n_tup_hot_upd) +
  (sut2.n_tup_ins - sut1.n_tup_ins) AS write_count,
  (sut2.idx_scan + sut2.seq_scan) - (sut1.idx_scan + sut1.seq_scan) AS no_of_reads,
  sut2.vacuum_count - sut1.vacuum_count AS vacuum_count_diff,
  sut2.autovacuum_count - sut1.autovacuum_count AS autovacuum_count_diff,
  sut2.analyze_count - sut1.analyze_count AS analyze_count_diff,
  sut2.autoanalyze_count - sut1.autoanalyze_count AS autoanalyze_count_diff
  FROM snapshots.snap_user_tables sut2
  JOIN snapshots.snap_user_tables sut1
  ON sut2.relid = sut1.relid
  -- end snap id
  WHERE sut2.snap_id = (SELECT max(snap_id) FROM snapshots.snap WHERE dttm <= now() )
  -- start snap id
  AND sut1.snap_id = (SELECT min(snap_id) FROM snapshots.snap WHERE dttm >= now() - INTERVAL '24' HOUR )
  -- filter the schemas
  AND sut2.schemaname IN ('ods','dw')
  AND sut2.vacuum_count - sut1.vacuum_count = 0
  AND sut2.autovacuum_count - sut1.autovacuum_count = 0
)
SELECT pt.oid::regclass, pt.size, pt.reltuples, pt.dead_rows
  -- ss.write_count, ss.no_of_reads, ss.vacuum_count_diff, ss.autovacuum_count_diff
FROM p2_tables pt
-- JOIN stats_snap ss
--  ON pt.oid = ss.relid
WHERE pt.reltuples <> 0
-- AND pt.dead_rows <> 0 AND ss.write_count <> 0 AND ss.no_of_reads <> 0
-- check if autovacuum/vacuum was ran in last 24 hours and skip those tables
AND date_part('day', now() - pt.last_autovacuum)*24 + date_part('hour', now() - pt.last_autovacuum) >= 24
AND date_part('day', now() - pt.last_vacuum)*24 + date_part('hour', now() - pt.last_vacuum) >= 24
ORDER BY 3 DESC;
