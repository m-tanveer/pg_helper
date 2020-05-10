-- cluster size
SELECT pg_size_pretty(sum(pg_database_size(d.datname))) AS cluster_size FROM pg_database d;

-- database size
SELECT d.datname AS db_name,
     pg_size_pretty(pg_database_size(d.datname)) AS db_size
FROM pg_database d
ORDER BY pg_database_size(d.datname) DESC;

-- Schema Size
SELECT schemaname, pg_size_pretty(SUM(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::BIGINT) FROM pg_tables group by schemaname ORDER BY SUM(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename))) DESC ;


-- total table size including index
select pg_size_pretty(pg_total_relation_size(cx_table_name)) ;

-- total table size without index
select pg_size_pretty(pg_relation_size(cx_table_name)) ;

-- index size of the table
select pg_size_pretty(pg_index_size(cx_index_name)) ;

-- table size ( Table Size + Index Size + Total Size)
SELECT QUOTE_IDENT(nspname)||'.'||QUOTE_IDENT( c.relname) as table_name, QUOTE_IDENT(i.relname) as index_name, ROUND(ROUND(100 * pg_relation_size(indexrelid) /pg_relation_size(indrelid), 2) / 100, 2) AS iratio, pg_size_pretty(pg_relation_size(indexrelid)) as index_size, pg_size_pretty(pg_relation_size(indrelid)) AS table_size, pg_relation_size(indexrelid) as isize_byte FROM pg_index x JOIN pg_class c ON c.oid = x.indrelid JOIN pg_class i ON i.oid = x.indexrelid JOIN pg_namespace n ON (n.oid =c.relnamespace) WHERE QUOTE_IDENT(nspname) NOT IN ('pg_catalog', 'information_schema', 'pg_toast','openscg','snapshots') AND i.relkind = 'i' AND c.relkind = 'r' AND pg_relation_size(indrelid) > 0  ORDER BY isize_byte desc limit 10;

-- table size ( Total Size )
SELECT relnamespace::regclass,
  relname,
  pg_size_pretty(pg_relation_size(pg_class.oid, 'main')) as main,
  pg_size_pretty(pg_relation_size(pg_class.oid, 'fsm')) as fsm,
  pg_size_pretty(pg_relation_size(pg_class.oid, 'vm')) as vm,
  pg_size_pretty(pg_relation_size(pg_class.oid, 'init')) as init,
  pg_size_pretty(pg_table_size(pg_class.oid)) as table,
  pg_size_pretty(pg_indexes_size(pg_class.oid)) as indexes,
  pg_size_pretty(pg_total_relation_size(pg_class.oid)) as total
FROM pg_class
WHERE relkind='r'
ORDER BY pg_total_relation_size(pg_class.oid) DESC
LIMIT 20;

-- table size ( Total Size ) -- in bytes 
SELECT relnamespace::regclass,
  relname,
  pg_relation_size(pg_class.oid, 'main') as main,
  pg_relation_size(pg_class.oid, 'fsm') as fsm,
  pg_relation_size(pg_class.oid, 'vm') as vm,
  pg_relation_size(pg_class.oid, 'init') as init,
  pg_table_size(pg_class.oid) as table,
  pg_indexes_size(pg_class.oid) as indexes,
  pg_total_relation_size(pg_class.oid) as total
FROM pg_class
WHERE relkind='r' and relname ='ledger_posting';

---
SELECT *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r'
  ) a
) a;

SELECT
   relname as Table,
   pg_size_pretty(pg_total_relation_size(relid)) As Size,
   pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as Index_Size
FROM pg_catalog.pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC;

-- Table Size ( Object Name + Object Type + No of Rows + Size )
SELECT
     relname AS objectname,
     relkind AS objecttype,
     reltuples AS rows,
     pg_size_pretty(relpages::bigint*8*1024) AS size
FROM pg_class
WHERE relpages >= 8
ORDER BY relpages DESC;

-- Row Size
SELECT octet_length(t::text) FROM _table_size_dbusf AS t;
