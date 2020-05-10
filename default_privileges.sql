--
-- grant permissions to the application user in the public schema
--

ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_user GRANT ALL on TABLES TO admindb ;
ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_user GRANT ALL on SEQUENCES TO admindb ;
ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_user GRANT ALL on FUNCTIONS TO admindb ;

--
-- revoke default privileges
--

ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_user REVOKE ALL on TABLES FROM admindb ;
ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_user REVOKE ALL on SEQUENCES FROM admindb ;
ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR ROLE master_user REVOKE ALL on FUNCTIONS FROM admindb ;

-- end of script
