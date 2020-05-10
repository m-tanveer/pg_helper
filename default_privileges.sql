--
-- grant permissions to the application user in the public schema
--

ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_prod GRANT ALL on TABLES TO anonuser ;
ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_prod GRANT ALL on SEQUENCES TO anonuser ;
ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_prod GRANT ALL on FUNCTIONS TO anonuser ;

--
-- revoke default privileges
--

ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_prod REVOKE ALL on TABLES FROM anonuser ;
ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_prod REVOKE ALL on SEQUENCES FROM anonuser ;
ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_prod REVOKE ALL on FUNCTIONS FROM anonuser ;

-- end of script 
