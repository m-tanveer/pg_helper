-- sample query to get the trigger details
-- select oid,* from pg_catalog.pg_trigger where tgrelid::regclass::varchar = 'payout_log' ;

-- pass the oid of the trigger to the function to get the definition of the trigger
-- select pg_get_triggerdef(18921);

-- create table to store the trigger information
create table if not exists public.disabled_triggers (
        seq bigserial primary key,
        schema text,
        relname text,
        tgname text
);

-- disabling the trigger
do $$ declare t record;
begin
for t in select n.nspname::varchar as trigger_table_schema, trig.tgrelid::regclass::varchar as trigger_table, trig.tgname::varchar from pg_catalog.pg_trigger trig
join pg_catalog.pg_class c on trig.tgrelid = c.oid
join pg_catalog.pg_namespace n on c.relnamespace = n.oid
where n.nspname = current_schema() and trig.tgname like 'bucardo%' and c.relname = 'payout_log'
  loop
    insert into public.disabled_triggers (schema, relname,tgname) values (t.trigger_table_schema, t.trigger_table, t.tgname);
    execute format('ALTER TABLE %s.%s DISABLE TRIGGER %s ;',  quote_ident(t.trigger_table_schema),quote_ident(t.trigger_table), quote_ident(t.tgname) );
  end loop;
end $$;

-- disbaled triggers
select 'ALTER TABLE ' || n.nspname || '.' || t.tgrelid::regclass || ' DISABLE TRIGGER ' || t.tgname || ';'
from pg_catalog.pg_trigger t
join pg_catalog.pg_class c
on t.tgrelid = c.oid
join pg_catalog.pg_namespace n
on c.relnamespace = n.oid
where n.nspname = current_schema()
and t.tgname like 'bucardo%'
;
