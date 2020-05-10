-- toast table analyze count
select s.schemaname,
  c.relname,
  pg_size_pretty(pg_relation_size(c.oid)),
  last_analyze,
  last_autoanalyze
  autoanalyze_count,
  analyze_count
from pg_class c
join pg_stat_all_tables s
on c.oid = s.relid
where relkind ='t'
order by pg_relation_size(c.oid) desc;


-- toast table vaccum count
select s.schemaname,
  c.relname,
  pg_size_pretty(pg_relation_size(c.oid)),
  last_vacuum,
  last_autovacuum,
  autovacuum_count,
  vacuum_count
from pg_class c
join pg_stat_all_tables s
on c.oid = s.relid
where relkind ='t'
order by pg_relation_size(c.oid) desc;


--
select 'analyze ' || s.schemaname || '.' || c.relname || ' ;'
from pg_class c
join pg_stat_all_tables s
on c.oid = s.relid
where relkind ='t'
order by pg_relation_size(c.oid) desc;
