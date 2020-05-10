-- https://www.postgresql.org/docs/10/monitoring-stats.html#WAIT-EVENT-TABLE

select datname,usename,wait_event_type,wait_event, count(1)
from pg_stat_activity group by 1,2,3,4 order by 5 desc;
