--
-- identify the orphan tables
--

select pgns.nspname as schema_name
, pgc.relname as object_name
from pg_class pgc
join pg_namespace pgns on pgc.relnamespace = pgns.oid
where pg_is_other_temp_schema(pgc.relnamespace);

--
-- generate the drop sql command 
--

select case when pgc.relname like '%_index'
then 'drop index ' || pgns.nspname || '.' || pgc.relname || ';'
else 'drop table ' || pgns.nspname || '.' || pgc.relname || ';' end as drop_query
from pg_class pgc
join pg_namespace pgns on pgc.relnamespace = pgns.oid
where pg_is_other_temp_schema(pgc.relnamespace)
and pgc.relname not like '%toast%';
