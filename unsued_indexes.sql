-- unused indexes in a database

SELECT
    now(),
    schemaname || '.' || relname AS table,
    indexrelname AS index,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
    idx_scan as index_scans,
    pg_get_indexdef(i.indexrelid)
FROM pg_stat_user_indexes ui
JOIN pg_index i ON ui.indexrelid = i.indexrelid
WHERE NOT indisunique AND idx_scan < 50 AND pg_relation_size(relid) > 5 * 8192
ORDER BY pg_relation_size(i.indexrelid) DESC LIMIT 20 ;



SELECT now(), schemaname || '.' || relname AS table, indexrelname AS index, pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size, idx_scan as index_scans,pg_get_indexdef(i.indexrelid) FROM pg_stat_user_indexes ui JOIN pg_index i ON ui.indexrelid = i.indexrelid WHERE NOT indisunique AND idx_scan < 50 AND pg_relation_size(relid) > 5 * 8192 ORDER BY pg_relation_size(i.indexrelid) DESC LIMIT 20 ;
