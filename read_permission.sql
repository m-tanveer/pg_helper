--
-- one time activity :
--
create role read_rubix;
grant connect on database corp to read_rubix;
grant usage on schema rubix to read_rubix ;
grant select on all tables in schema rubix to read_rubix;
grant select on all SEQUENCes in schema rubix to read_rubix ;

--
-- granting read permissions to a user
--

grant read_rubix to javid ;
