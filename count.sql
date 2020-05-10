

WITH params AS (
    SELECT 1       AS min_id           -- minimum id <= current min id
         , 5100000 AS id_span          -- rounded up. (max_id - min_id + buffer)
    )
SELECT *
FROM  (
    SELECT p.min_id + trunc(random() * p.id_span)::integer AS id
    FROM   params p
          ,generate_series(1, 1100) g  -- 1000 + buffer
    GROUP  BY 1                        -- trim duplicates
    ) r
JOIN transactions_p2018_06 USING (id)
LIMIT  1000;                           -- trim surplus


--
-- below will work well for the integers 
--

SELECT -- count(*) AS ct,              -- optional
     min(createdat)  AS min_id
     , max(createdat)  AS max_id
     , max(createdat) - min(createdat) AS id_span
FROM   transactions_p2015_09;
