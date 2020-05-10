create or replace function subtxn(cnt int) returns int as $$
BEGIN
FOR i IN 1 .. cnt LOOP
BEGIN
insert into t values (i, 'XXX');
cnt := cnt;
EXCEPTION
WHEN division_by_zero THEN
cnt := cnt;
END;
END LOOP;
return 0;
END; $$LANGUAGE 'plpgsql';

drop table if exists t;
create table t (i int primary key, c char(3));
select subtxn(2000000);
