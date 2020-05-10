---
WITH archive AS (
    DELETE FROM source WHERE ...
 RETURNING s.id
)
INSERT INTO target(id, counter) SELECT * FROM archive;

---
DELETE FROM the_table WHERE the_timestamp < now() - INTERVAL '7 days'

----
DELETE FROM tempoffset WHERE ts_insert < now()-'1 hour'::INTERVAL;

---
WITH row_batch AS (
   SELECT id FROM public.notifications_old
      WHERE updated_at >= '2016-10-18 00:00:00'::timestamp LIMIT 20000 ),
delete_rows AS (
   DELETE FROM public.notifications_old o USING row_batch b
      WHERE b.id = o.id
      RETURNING o.id, account_id, created_at, updated_at, resource_id, notifier_id, notifier_type
)
INSERT INTO public.notifications SELECT * FROM delete_rows;
