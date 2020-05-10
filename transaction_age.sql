-- max cluster transaction age
select max(age(datfrozenxid)) from pg_database;

-- databases transaction age
SELECT datname, age(datfrozenxid) FROM pg_database WHERE datname NOT IN ('postgres','template1','template0') ORDER BY age(datfrozenxid) DESC;

-- table transaction age
SELECT pg_class.oid::regclass AS full_table_name,
  greatest(age(pg_class.relfrozenxid),
  age(toast.relfrozenxid)) as freeze_age,
  pg_size_pretty(pg_relation_size(pg_class.oid)) as size
FROM pg_class
JOIN pg_namespace
  ON pg_class.relnamespace = pg_namespace.oid
LEFT OUTER JOIN pg_class as toast
  ON pg_class.reltoastrelid = toast.oid
WHERE nspname not in ('pg_catalog', 'information_schema')
AND nspname NOT LIKE 'pg_temp%'
AND pg_class.relkind IN ('r','t')
ORDER BY freeze_age DESC, pg_relation_size(pg_class.oid) DESC;

-- table transaction age improved
SELECT oid::regclass::text AS table,
  age(relfrozenxid) AS xid_age,
  mxid_age(relminmxid) AS mxid_age,
  least( (SELECT setting::int FROM pg_settings WHERE name = 'autovacuum_freeze_max_age') - age(relfrozenxid), (SELECT setting::int FROM pg_settings WHERE name = 'autovacuum_multixact_freeze_max_age') - mxid_age(relminmxid)) AS tx_before_wraparound_vacuum,
  pg_size_pretty(pg_total_relation_size(oid)) AS size,
  pg_stat_get_last_autovacuum_time(oid) AS last_autovacuum
FROM pg_class
WHERE not (relfrozenxid = 0)
AND oid > 16384
ORDER BY tx_before_wraparound_vacuum;

-- with av_wrap_pct / shutdown_pct percentage 
with relage as (
select relname, age(relfrozenxid) as xid_age,
    round((relpages/128::numeric),1) as mb_size
    from pg_class
where relkind IN ('r', 't','m')
),
av_max_age as (
    select setting::numeric as max_age from pg_settings where name = 'autovacuum_freeze_max_age'
),
wrap_pct AS (
select relname, xid_age,
    round(xid_age*100::numeric/max_age, 1) as av_wrap_pct,
    round(xid_age*100::numeric/2200000000, 1) as shutdown_pct,
    mb_size
from relage cross join av_max_age
)
select wrap_pct.*
from wrap_pct
where ((av_wrap_pct >= 75
    or shutdown_pct >= 50)
    and mb_size > 1000)
    or
    (av_wrap_pct > 100
    or shutdown_pct > 80)
order by xid_age desc;
