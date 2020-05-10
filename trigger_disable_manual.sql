-- disbaled triggers
select 'ALTER TABLE ' || n.nspname || '.' || t.tgrelid::regclass || ' ENABLE TRIGGER ' || t.tgname || ';'
from pg_catalog.pg_trigger t
join pg_catalog.pg_class c
on t.tgrelid = c.oid
join pg_catalog.pg_namespace n
on c.relnamespace = n.oid
where n.nspname = current_schema()
and t.tgname like 'bucardo%'
;
