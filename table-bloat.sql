WITH table_bloat AS (
  SELECT current_database(),
    schemaname,
    tblid,
    tblname,
    bs*tblpages AS real_size,
    REPLACE(pg_size_pretty(bs*tblpages::numeric), ' ','') as real_size_pretty,
    fillfactor,
    (tblpages - est_tblpages_ff)*bs AS bloat_size,
    CASE
      WHEN tblpages - est_tblpages_ff > 0
      THEN round((100 * (tblpages - est_tblpages_ff)/tblpages::float)::numeric,2)
      ELSE 0
    END AS bloat_ratio,
    is_na
    -- , (pst).free_percent + (pst).dead_tuple_percent AS real_frag
  FROM (
    SELECT ceil( reltuples / ( (bs-page_hdr)/tpl_size ) ) + ceil( toasttuples / 4 ) AS est_tblpages,
      ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
      tblpages,
      fillfactor,
      bs,
      tblid,
      schemaname,
      tblname,
      heappages,
      toastpages,
      is_na
      -- , stattuple.pgstattuple(tblid) AS pst
    FROM (
      SELECT
        ( 4 + tpl_hdr_size + tpl_data_size + (2*ma)
          - CASE WHEN tpl_hdr_size%ma = 0 THEN ma ELSE tpl_hdr_size%ma END
          - CASE WHEN ceil(tpl_data_size)::int%ma = 0 THEN ma ELSE ceil(tpl_data_size)::int%ma END
        ) AS tpl_size, bs - page_hdr AS size_per_block,
        (heappages + toastpages) AS tblpages, heappages,
        toastpages,
        reltuples,
        toasttuples,
        bs,
        page_hdr,
        tblid,
        schemaname,
        tblname,
        fillfactor,
        is_na
      FROM (
        SELECT
          tbl.oid AS tblid,
          ns.nspname AS schemaname,
          tbl.relname AS tblname,
          tbl.reltuples,
          tbl.relpages AS heappages,
          coalesce(toast.relpages, 0) AS toastpages,
          coalesce(toast.reltuples, 0) AS toasttuples,
          coalesce(substring(array_to_string(tbl.reloptions, ' ') FROM '%fillfactor=#"__#"%' FOR '#')::smallint, 100) AS fillfactor,
          current_setting('block_size')::numeric AS bs,
          CASE WHEN version()~'mingw32' OR version()~'64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END AS ma,
          24 AS page_hdr,
          23 + CASE WHEN MAX(coalesce(null_frac,0)) > 0 THEN ( 7 + count(*) ) / 8 ELSE 0::int END + CASE WHEN tbl.relhasoids THEN 4 ELSE 0 END AS tpl_hdr_size,
          sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 1024) ) AS tpl_data_size,
          bool_or(att.atttypid = 'pg_catalog.name'::regtype) AS is_na
        FROM pg_attribute AS att
          JOIN pg_class AS tbl ON att.attrelid = tbl.oid
          JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
          JOIN pg_stats AS s ON s.schemaname=ns.nspname
            AND s.tablename = tbl.relname
            AND s.inherited=false AND s.attname=att.attname
          LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
        WHERE att.attnum > 0 AND NOT att.attisdropped
          -- only archive schema
          AND ns.nspname IN ('ods')
          AND tbl.relkind = 'r'
        GROUP BY 1,2,3,4,5,6,7,8,9,10, tbl.relhasoids
        ORDER BY 2,3
      ) AS s
    ) AS s2
  ) AS s3
  ORDER BY bloat_size DESC
)
,
table_bloated_stats as (
SELECT current_database(),
  sut2.schemaname  AS schema,
  t.oid,
  sut2.relname AS table_name,
  sut2.n_tup_upd - sut1.n_tup_upd AS no_of_updates,
  sut2.n_tup_hot_upd - sut1.n_tup_hot_upd AS no_of_hot_updates,
  sut2.n_tup_del - sut1.n_tup_del AS no_of_deletes,
  sut2.n_tup_ins - sut1.n_tup_ins AS no_of_inserts,

  -- (sut2.seq_tup_read+sut2.idx_tup_fetch) - (sut1.seq_tup_read+sut1.idx_tup_fetch) AS no_of_rows_reads,
  (sut2.idx_scan + sut2.seq_scan) - (sut1.idx_scan + sut1.seq_scan) AS no_of_reads,
  t.relpages,
  t.reltuples AS estimated_rows,
  sut2.n_live_tup AS live_rows,
  sut2.n_dead_tup AS dead_rows,
  COALESCE(pg_table_size(sut2.relid),'0') AS table_size_bytes,
  COALESCE(NULLIF(pg_size_pretty(pg_table_size(sut2.relid)),''),'0') AS table_size,
  sut2.vacuum_count - sut1.vacuum_count AS vacuum_count_diff,
  sut2.autovacuum_count - sut1.autovacuum_count AS autovacuum_count_diff,
  sut2.analyze_count - sut1.analyze_count AS analyze_count_diff,
  sut2.autoanalyze_count - sut1.autoanalyze_count AS autoanalyze_count_diff,
  sut2.last_autovacuum::TIMESTAMP(0),
  sut2.last_autoanalyze::TIMESTAMP(0),
  sut2.last_vacuum::TIMESTAMP(0),
  sut2.last_analyze::TIMESTAMP(0),
  (sut2.n_tup_upd - sut1.n_tup_upd) + (sut2.n_tup_del - sut1.n_tup_del) + (sut2.n_tup_ins - sut1.n_tup_ins) AS write_count
FROM snapshots.snap_user_tables sut2
  JOIN snapshots.snap_user_tables sut1
    ON sut2.relid = sut1.relid
  JOIN pg_class t  -- to get the fillfactor value
    ON t.oid = sut2.relid
  JOIN pg_namespace n -- to get the fillfactor value
    ON n.oid = t.relnamespace
    -- filter the schemas
WHERE sut2.schemaname IN ('ods')
-- WHERE sut2.schemaname IN ('ods')
  -- end snap id
  AND sut2.snap_id = (SELECT max(snap_id) FROM snapshots.snap WHERE dttm < '2017-12-20 18:00:00')
  -- start snap id
  AND sut1.snap_id = (SELECT min(snap_id) FROM snapshots.snap WHERE dttm > '2017-12-20 03:00:00')
)

/*
select * from table_bloated_stats  tbs
join table_bloat tb
on  tbs.oid = tb.tblid
WHERE tb.bloat_ratio > 20;
*/

SELECT schemaname,
  tblid,
  tblname,
  real_size_pretty,
  fillfactor,
  REPLACE(pg_size_pretty(bloat_size::numeric),' ','') as bloat_size_pretty,
  coalesce(bloat_size::numeric, 0) as bloat_size,
  bloat_ratio,
  -- round(bloat_ratio::numeric,2) as bloat_ratio,
  is_na
FROM table_bloat
--WHERE tblid = '1986299003'
WHERE bloat_ratio > 20
ORDER BY 7 DESC;
