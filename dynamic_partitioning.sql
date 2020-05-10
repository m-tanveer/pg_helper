-- number generator for id
CREATE SEQUENCE chat_id_seq;

CREATE TABLE public.chat_master
(
    id integer NOT NULL DEFAULT nextval('chat_id_seq'::regclass),
    program_id character varying COLLATE pg_catalog."default",
    user_id character varying COLLATE pg_catalog."default",
    dialogue character varying(10000) COLLATE pg_catalog."default",
    created_at timestamp without time zone
)
TABLESPACE pg_default;


CREATE INDEX idx_program_id
    ON public.chat_master USING hash
    (program_id COLLATE pg_catalog."default")
    TABLESPACE pg_default;

CREATE INDEX idx_user_id
    ON public.chat_master USING hash
    (user_id COLLATE pg_catalog."default")
    TABLESPACE pg_default;

CREATE INDEX idx_created_at ON public.chat_master ((created_at::DATE));



CREATE OR REPLACE FUNCTION chat_insert_function()
RETURNS TRIGGER AS $$
DECLARE
	partition_date TEXT;
	partition_name TEXT;
	start_of_month TEXT;
	end_of_next_month TEXT;
BEGIN
	partition_date := to_char(NEW.created_at,'YYYY_MM');
 	partition_name := 'chat_' || partition_date;
	start_of_month := to_char((NEW.created_at),'YYYY-MM') || '-01';
	end_of_next_month := to_char((NEW.created_at + interval '1 month'),'YYYY-MM') || '-01';
IF NOT EXISTS
	(SELECT 1
   	 FROM   information_schema.tables
   	 WHERE  table_name = partition_name)
THEN
	RAISE NOTICE 'A partition has been created %', partition_name;
	EXECUTE format(E'CREATE TABLE %I (CHECK ( date_trunc(\'day\', created_at) >= ''%s'' AND date_trunc(\'day\', created_at) < ''%s'')) INHERITS (public.chat_master)', partition_name, start_of_month,end_of_next_month);
	-- EXECUTE format('GRANT SELECT ON TABLE %I TO readonly', partition_name); -- use this if you use role based permission
END IF;
EXECUTE format('INSERT INTO %I (program_id, user_id, dialogue, created_at) VALUES($1,$2,$3,$4)', partition_name) using NEW.program_id, NEW.user_id, NEW.dialogue, NEW.created_at;
RETURN NULL;
END
$$
LANGUAGE plpgsql;


CREATE TRIGGER insert_chat_trigger
BEFORE INSERT ON public.chat_master
FOR EACH ROW EXECUTE PROCEDURE public.chat_insert_function();


INSERT INTO public.chat_master (
program_id, user_id, dialogue, created_at)
VALUES ('program_1', 'A01', 'hello world!', '2018-11-11'
);

INSERT INTO public.chat_master (
 program_id, user_id, dialogue, created_at)
 VALUES ('program_2', 'A01', 'hello panya!', '2018-12-12'
);
NOTICE:  A partition has been created chat_2018_12
INSERT 0 0

SELECT * FROM chat_master
|id | program_id  |user_id|   dialogue     | created_at
-----------------------------------------------------------------
| 2 | "program_1" | "A01" | "hello world!" | "2018-11-11 00:00:00"
| 3 | "program_2" | "A01" | "hello panya!" | "2018-12-12 00:00:00"
SELECT * FROM chat_2018_12
|id | program_id  |user_id|   dialogue     | created_at
-----------------------------------------------------------------
| 2 | "program_2" | "A01" | "hello panya!" | "2018-12-12 00:00:00"


-- https://read.acloud.guru/how-to-partition-dynamically-in-postgresql-ce3acbaef66c    
