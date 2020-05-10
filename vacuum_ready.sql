WITH
vbt AS (
  SELECT setting AS autovacuum_vacuum_threshold    FROM pg_settings WHERE name = 'autovacuum_vacuum_threshold'
),
vsf AS (
  SELECT setting AS autovacuum_vacuum_scale_factor FROM pg_settings WHERE name = 'autovacuum_vacuum_scale_factor'
),
fma AS (
  SELECT setting AS autovacuum_freeze_max_age      FROM pg_settings WHERE name = 'autovacuum_freeze_max_age'
),
sto AS (
  SELECT opt_oid,
      split_part(setting, '=', 1) AS param,
      split_part(setting, '=', 2) AS value
  FROM (
        SELECT oid opt_oid, unnest(reloptions) setting FROM pg_class
  ) opt
)

SELECT
    ns.nspname as schema
    , c.relname AS table 
    , pg_size_pretty(pg_table_size(c.oid)) AS table_size
    , age(relfrozenxid) AS xid_age
    , coalesce(cfma.value::float, autovacuum_freeze_max_age::float) AS autovacuum_freeze_max_age
    , ( coalesce(cvbt.value::float, autovacuum_vacuum_threshold::float) + coalesce(cvsf.value::float, autovacuum_vacuum_scale_factor::float) * c.reltuples) AS autovacuum_vacuum_threshold
    --, coalesce(cvbt.value::float, autovacuum_vacuum_threshold::float) + coalesce(cvsf.value::float, 0.2::float) * reltuples as autovacuum_vacuum_tuples
    , n_dead_tup AS dead_tuples
FROM pg_class c
JOIN pg_namespace ns         ON ns.oid     = c.relnamespace
JOIN pg_stat_all_tables stat ON stat.relid = c.oid
JOIN vbt                     ON (1=1)
JOIN vsf                     ON (1=1)
JOIN fma                     ON (1=1)
LEFT JOIN sto cvbt           ON cvbt.param = 'autovacuum_vacuum_threshold'    AND c.oid = cvbt.opt_oid
LEFT JOIN sto cvsf           ON cvsf.param = 'autovacuum_vacuum_scale_factor' AND c.oid = cvsf.opt_oid
LEFT JOIN sto cfma           ON cfma.param = 'autovacuum_freeze_max_age'      AND c.oid = cfma.opt_oid
WHERE c.relkind = 'r'
  AND nspname <> 'pg_catalog'
  -- AND ( age(relfrozenxid) >= coalesce(cfma.value::float, autovacuum_freeze_max_age::float)
  --  or
  AND n_dead_tup::float >= coalesce(cvbt.value::float, autovacuum_vacuum_threshold::float) + coalesce(cvsf.value::float, autovacuum_vacuum_scale_factor::float) * c.reltuples
ORDER BY 7 DESC
;
