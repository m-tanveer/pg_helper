--
-- database transactions
--

select now(),datname,numbackends,xact_commit,xact_rollback,tup_returned,tup_fetched,tup_inserted,tup_updated,tup_deleted from pg_stat_database where datname in ('payment','wallet','cloud_card');
