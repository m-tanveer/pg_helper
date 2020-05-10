
-- termination count by time range
SELECT log_time::date,
  count(*)
FROM stat_statements.terminate_log
WHERE log_time::date > '2017-12-13'
AND log_time::date  < '2017-12-23'
GROUP BY 1
ORDER BY 1 DESC;

-- termination count by hour
SELECT log_time::date AS date,
  date_part('hour',log_time) AS time,
  dat_name AS database,
  -- log_time::time(0) AS time,
  count(*)  AS termination_count
FROM stat_statements.terminate_log
WHERE log_time::date = now()::date
GROUP BY 1,2,3
ORDER BY 1 DESC;

-- termination cout by query
SELECT log_time::date AS date,
  date_part('hour',log_time) AS hour,
  dat_name AS database,
  count(*) AS count,
  regexp_replace(query,'[\s\u2028]+', ' ', 'g') AS terminated_query
FROM stat_statements.terminate_log
-- WHERE log_time::date = now()::date
WHERE log_time::date > '2018-01-08'
AND log_time::date <= '2018-01-10'
GROUP BY 1,2,3,5
ORDER BY 1, 2 DESC;


-- query termination report
SELECT log_time::date AS date,
  date_part('hour',log_time) AS hour,
  dat_name AS database,
  count(*) AS count,
  max(duration)::time(0) as max_time,
  min(duration)::time(0) as min_time,
  avg(duration)::time(0) as avg_time,
  -- sum(duration)::time(0) as total_time,
  regexp_replace(query,'[\s\u2028]+', ' ', 'g') AS terminated_query
FROM stat_statements.terminate_log
-- WHERE log_time::date = now()::date
WHERE log_time::date > '2018-01-08'
AND log_time::date <= '2018-01-10'
GROUP BY 1,2,3,8
ORDER BY 1, 2;
