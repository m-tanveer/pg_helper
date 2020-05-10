---
--- Create parent table  Insert data
---

CREATE TABLE jane (id serial PRIMARY KEY, record_time TIMESTAMP NOT NULL, level INTEGER, msg TEXT);

---
--- Insert data into parent table
---

INSERT INTO jane (record_time, level, msg)
    SELECT tz,random() * 6 as rand, md5(tz::text)
FROM generate_series('2018-01-01 00:00'::timestamp,'2018-07-31 12:00', '1 minute') as tz ;

---
--- Create child table
---

CREATE TABLE jane_p2018_01 (
    CHECK ( record_time >= DATE '2018-01-01' AND record_time < DATE '2018-02-01' )
) INHERITS (jane);

CREATE TABLE jane_p2018_02 (
    CHECK ( record_time >= DATE '2018-02-01' AND record_time < DATE '2018-03-01' )
) INHERITS (jane);

CREATE TABLE jane_p2018_03 (
    CHECK ( record_time >= DATE '2018-03-01' AND record_time < DATE '2018-04-01' )
) INHERITS (jane);

CREATE TABLE jane_p2018_04 (
    CHECK ( record_time >= DATE '2018-04-01' AND record_time < DATE '2018-05-01' )
) INHERITS (jane);

---
--- create index on the key column
---

CREATE INDEX jane_p2018_01_date_idx ON jane_p2018_01 (record_time);
CREATE INDEX jane_p2018_01_date_idx ON jane_p2018_02 (record_time);
CREATE INDEX jane_p2018_01_date_idx ON jane_p2018_03 (record_time);
CREATE INDEX jane_p2018_01_date_idx ON jane_p2018_04 (record_time);

---
--- create function to invoke trigger
---

CREATE OR REPLACE FUNCTION jane_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF ( NEW.record_time >= DATE '2018-01-01' AND
         NEW.record_time < DATE '2018-02-01' ) THEN
        INSERT INTO jane_p2018_01 VALUES (NEW.*);
    ELSIF ( NEW.record_time >= DATE '2018-02-01' AND
            NEW.record_time < DATE '2018-03-01' ) THEN
        INSERT INTO jane_p2018_02 VALUES (NEW.*);
    ELSIF ( NEW.record_time >= DATE '2018-03-01' AND
            NEW.record_time < DATE '2018-04-01' ) THEN
        INSERT INTO jane_p2018_03 VALUES (NEW.*);
    ELSIF ( NEW.record_time >= DATE '2018-04-01' AND
            NEW.record_time < DATE '2018-05-01' ) THEN
        INSERT INTO jane_p2018_04 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Date out of range.  Fix the jane_insert_trigger() function!';
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

---
--- create insert trigger
---

CREATE TRIGGER insert_jane_trigger
    BEFORE INSERT ON jane
FOR EACH ROW EXECUTE PROCEDURE jane_insert_trigger();

---
--- move existing data from parent to child table
---

WITH deleted as (
    DELETE FROM jane where record_time >= '2018-01-01' and record_time < '2018-02-01'
    RETURNING *
)
INSERT INTO jane (record_time, level, msg) SELECT record_time, level, msg FROM deleted ;

---
--- clean up
---

DROP TABLE jane CASCADE ;

---
--- end of story
---


---
--- partman
---

CREATE TABLE partman_table (id serial, record_time TIMESTAMP NOT NULL, level INTEGER, msg TEXT);

INSERT INTO partman_table (record_time, level, msg)
    SELECT tz,random() * 6 as rand, md5(tz::text)
FROM generate_series('2018-01-01 00:00'::timestamp,'2018-07-31 12:00', '1 minute') as tz;

SELECT create_parent(''partman_table'',''record_time'',''time-static'',''monthly'', NULL, 1);

---
--- research --- begins
---

--- select to_timestamp(overlay(created placing '.' from 10 ):: double precision) from transactions limit 10 ;

--- unix epoch time stamp default in seconds
--- n26 uses unix epoch timestamp in milliseconds

SELECT to_timestamp(created::bigint / 1000) from transactions ;

--- group by year

SELECT date_part('year',to_timestamp(created::bigint / 1000)), count(1) from transactions group by 1 ;

--- group by month

SELECT date_part('year',to_timestamp(created::bigint / 1000)),
  date_part('month',to_timestamp(created::bigint / 1000)),
  count(2)
from transactions group by 1,2 ;

SELECT timestamp 'epoch' + created * interval '1 ms' from transactions ;

---
--- research --- begins
---
