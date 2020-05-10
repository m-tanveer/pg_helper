-- truncate bucardo tables
select 'TRUNCATE ' || n.nspname || '.' || c.relname || ';'
from pg_catalog.pg_class c
join pg_catalog.pg_namespace n
on c.relnamespace = n.oid
where n.nspname = 'bucardo'
and c.relkind = 'r'
order by 1 desc
;

select 'TRUNCATE ' || n.nspname || '.' || c.relname || ';'
from pg_catalog.pg_class c
join pg_catalog.pg_namespace n
on c.relnamespace = n.oid
where n.nspname = 'corp'
and c.relkind = 'r'
order by 1 desc
;
