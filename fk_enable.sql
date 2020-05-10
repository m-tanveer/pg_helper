-- print current value
SHOW session_replication_role ;

-- re-enabling the triggers
set session_replication_role = default;

-- verify the setting
-- should be set to origin
SHOW session_replication_role ;

-- recreating the triggers
do $$ declare t record;
begin
    -- order by seq for easier troubleshooting when data does not satisfy FKs
    for t in select * from public.dropped_foreign_keys order by seq loop
        execute t.sql;
        delete from public.dropped_foreign_keys where seq = t.seq;
    end loop;
end $$;

-- end of script
