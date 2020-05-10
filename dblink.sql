-- create extension
CREATE EXTENSION dblink;

-- test the host connectivity
SELECT dblink_connect('host=localhost user=read_fdw_preprod password=***** dbname=admindb');

-- create the remote server
CREATE SERVER admindb_dblink FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'admindb', port '5432');

-- create user mapping
CREATE USER MAPPING FOR flyway_preprod SERVER admindb_dblink OPTIONS ( "user" 'read_fdw_preprod', password '******') ;

-- test the server connnection
SELECT dblink_connect('admindb_dblink');

-- run a test function
SELECT * FROM dblink('admindb_dblink', $$select * from get_tables('public')$$) as data(schema_name text, relation_name text);
