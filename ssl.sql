CREATE EXTENSION sslinfo ;

SHOW ssl;

SELECT ssl_is_used() ;

SELECT * FROM pg_stat_ssl;


-- verify ssl connectivity for a specific database
select
  datname,
  usename ,
  client_addr,
  state,
  ssl,
  version,
  cipher,
  bits,
  count(*)
from pg_stat_activity
join pg_stat_ssl
on pg_stat_activity.pid = pg_stat_ssl.pid
-- where datname ='calypso'
group by 1,2,3,4,5,6,7,8
order by 9 desc ;


-- show connections with ssl connection for a specific database
select datname, usename , client_addr,state, ssl, version, cipher, bits, count(*)
from pg_stat_activity
join pg_stat_ssl
on pg_stat_activity.pid = pg_stat_ssl.pid
where  datname in ('settlement', 'cerberus2', 'cerberus_oauth')
-- and ssl=false
group by 1,2,3,4,5,6,7,8 order by 9 desc ;
