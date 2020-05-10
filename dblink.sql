-- create extension
CREATE EXTENSION dblink;

-- test the host connectivity
SELECT dblink_connect('host=alldb-preprod.c8enwqlkg9hw.ap-south-1.rds.amazonaws.com user=read_fdw_preprod password=xVmews9maPWrslPwar6M dbname=ledger');

-- create the remote server
CREATE SERVER ledger_master_current_dblink FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'alldb-preprod.c8enwqlkg9hw.ap-south-1.rds.amazonaws.com', dbname 'ledger', port '5432');

-- create user mapping
CREATE USER MAPPING FOR flyway_preprod SERVER ledger_master_current_dblink OPTIONS ( "user" 'read_fdw_preprod', password 'xVmews9maPWrslPwar6M') ;

-- test the server connnection
SELECT dblink_connect('ledger_master_current_dblink');

-- run a test function
SELECT * FROM dblink('ledger_master_current_dblink', $$select * from get_tables('public')$$) as data(schema_name text, relation_name text);
