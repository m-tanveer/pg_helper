select conname, conrelid::regclass, pg_catalog.pg_get_constraintdef(oid) from pg_constraint;

CREATE OR REPLACE FUNCTION admin.show_foreign_keys(tablename text)
 RETURNS TABLE(table1 text, column1 text, type text, table2 text, column2 text)
 LANGUAGE plpgsql
AS $function$
    declare
        schemaname text;
    begin
        select into schemaname current_schema();
        return query
        execute format('
        select
            conrelid::regclass::text as table1,
            a.attname::text as column1,
            t.typname::text as type,
            confrelid::regclass::text as table2,
            af.attname::text as column2
        from
            pg_attribute af,
            pg_attribute a,
            pg_type t,
            (
                select
                    conrelid,
                    confrelid,
                    conkey[i] as conkey,
                    confkey[i] as confkey
                from (
                    select
                        conrelid,
                        confrelid,
                        conkey,
                        confkey,
                        generate_series(1,array_upper(conkey,1)) as i
                    from
                        pg_constraint
                    where contype = ''f''
                    )
                ss) ss2
        where
            af.attnum = confkey and
            af.attrelid = confrelid and
            a.attnum = conkey and
            a.attrelid = conrelid and
            a.atttypid = t.oid and
            confrelid::regclass = ''%I.%I''::regclass
         order by 1,2;',schemaname,tablename);
    end;
$function$
