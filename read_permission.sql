--
-- one time activity :
--
create role read_admindb;
grant connect on database corp to read_admindb;
grant usage on schema admindb to read_admindb ;
grant select on all tables in schema admindb to read_admindb;
grant select on all SEQUENCes in schema admindb to read_admindb ;

--
-- granting read permissions to a user
--

grant read_admindb to mtanveer ;
