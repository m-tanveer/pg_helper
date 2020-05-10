-- create transactions table
create table public.transactions (
  id bigserial not null,
  created timestamp without time zone default now(),
  datname text not null,
  xact_commit bigint not null,
  xact_rollback bigint not null
);

-- index if the table data is too huge
create index transactions_created_idx on public.transactions(created);

-- insert the data every 1 min
insert into public.transactions (datname,xact_commit,xact_rollback)
  select  datname, xact_commit,xact_rollback from pg_stat_database;

-- transactions diff between duration
select datname,
  max(xact_commit + xact_rollback) - min(xact_commit + xact_rollback) as transactions
from public.transactions
where created > now() - '2 minutes'::interval
group by 1
order by 2 desc
LIMIT 20;

-- truncate the table if the size has grown higher
truncate public.transactions;


-- end of script
