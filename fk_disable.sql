-- set the session role to replica
set session_replication_role = replica;

-- create table to store the foreign key information
create table if not exists public.dropped_foreign_keys (
        seq bigserial primary key,
        sql text
);

-- dropping the constraints
do $$ declare t record;
begin
    for t in select n.nspname::varchar as schema_name ,conrelid::regclass::varchar table_name, conname constraint_name,
            pg_catalog.pg_get_constraintdef(r.oid, true) constraint_definition
            from pg_catalog.pg_constraint r
            join pg_catalog.pg_namespace n
            on r.connamespace = n.oid
            where r.contype = 'f'
            -- current schema only:
            and r.connamespace = (select n.oid from pg_namespace n where n.nspname = current_schema())
        loop

        insert into public.dropped_foreign_keys (sql) values (
            format('alter table %s.%s add constraint %s %s',
                quote_ident(t.schema_name),quote_ident(t.table_name), quote_ident(t.constraint_name), t.constraint_definition));

        execute format('alter table %s.%s drop constraint %s', t.schema_name, t.table_name, quote_ident(t.constraint_name));

    end loop;
end $$;

-- end of state


-- select n.nspname::varchar as schema_name ,conrelid::regclass::varchar table_name, conname constraint_name,
-- pg_catalog.pg_get_constraintdef(r.oid, true) constraint_definition
-- from pg_catalog.pg_constraint r
-- join pg_catalog.pg_namespace n
-- on r.connamespace = n.oid
-- where conrelid::regclass::varchar = 'payout_log' ;
