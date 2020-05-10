-- script to fix the quotes in the order table name
-- current state : alter table corp."""order""" add constraint order_ibfk_2 FOREIGN KEY (companyid) REFERENCES company(id) ON UPDATE RESTRICT ON DELETE RESTRICT
-- new state : alter table corp.order add constraint order_ibfk_2 FOREIGN KEY (companyid) REFERENCES company(id) ON UPDATE RESTRICT ON DELETE RESTRICT

begin ;

-- view the row
select * from corp.dropped_foreign_keys where seq = 288;

-- update the row
update corp.dropped_foreign_keys
set sql = 'alter table corp.order add constraint order_ibfk_2 FOREIGN KEY (companyid) REFERENCES company(id) ON UPDATE RESTRICT ON DELETE RESTRICT'
where seq = 288;

--verify the row
select * from corp.dropped_foreign_keys where seq = 288;

commit

--  end of script 
