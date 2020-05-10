--
SELECT now()::timestamp(0), relname , last_autovacuum::timestamp(0) , last_autoanalyze::timestamp(0) ,
  last_vacuum::timestamp(0) , last_analyze::timestamp(0)
FROM pg_stat_user_tables
WHERE last_autovacuum::date = '2019-08-22' OR last_vacuum::date = '2019-08-22';

-- tables not vacuumed or analyzed in last 24 hours
SELECT now()::timestamp(0), relname , last_autovacuum::timestamp(0) , last_autoanalyze::timestamp(0) ,
  last_vacuum::timestamp(0) , last_analyze::timestamp(0)
FROM pg_stat_user_tables
WHERE last_autovacuum::date <= now() - '24 HOURS'::INTERVAL
OR last_autoanalyze::date <= now() - '24 HOURS'::INTERVAL;

-- list dead tuples 
select
      sat.relname
      ,sat.n_dead_tup
      ,sat.n_live_tup
      ,to_char(sat.last_autovacuum, 'YYYY-MM-DD HH24:MI:SS') last_autovacuum
      ,sat.autovacuum_count
      ,to_char(sat.last_vacuum, 'YYYY-MM-DD HH24:MI:SS') last_vacuum
      ,sat.vacuum_count
      ,sat.seq_scan
      ,sat.idx_scan
from pg_stat_all_tables sat
where sat.n_dead_tup != 0
order by sat.n_dead_tup desc;
