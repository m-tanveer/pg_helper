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
  -- AND sut1.relname in ('hos_hos_daily_calculation_p2018_01','hos_hos_daily_calculation_p2018_02','hos_hos_daily_calculation_p2017_12','hos_hos_daily_calculation_p2017_11')
  AND sut1.relid in ('1986299003')
  -- end snap id
  AND sut2.snap_id = (SELECT max(snap_id) FROM snapshots.snap WHERE dttm < '2018-01-10 01:21:06')
  -- start snap id
  AND sut1.snap_id = (SELECT min(snap_id) FROM snapshots.snap WHERE dttm > '2018-01-09 07:00:00')

  -- AND t.reltuples <> 0
  -- AND sut2.vacuum_count - sut1.vacuum_count > 0
  -- AND sut2.autovacuum_count - sut1.autovacuum_count > 0
;
