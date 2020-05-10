select msgid_seq, count(*) from activemq_msgs group by 1 order by 1 ;

-- sample data 
--  msgid_seq | count
-- -----------+--------
--          1 | 127975
--          2 |      4
--          3 |      4
--          4 |      4
--          5 |      4
--          6 |      4
--          7 |      4
--          8 |      4
--          9 |      4
--         10 |      3
--         11 |      2
--         12 |      2
--         13 |      2
--         14 |      1
