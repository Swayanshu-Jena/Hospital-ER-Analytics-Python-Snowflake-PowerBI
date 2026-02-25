-- Step 1: Demonstrate Result Caching

-- Run this query ONCE. Look at the execution time in the bottom right corner (e.g., 500ms).
SELECT department_routed, triage_level, AVG(wait_time_minutes) as avg_wait
FROM hospital_db.emergency_analytics.fact_er_visits
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Now, run the EXACT same query a SECOND time immediately. 
-- Look at the time again. It should drop to something tiny like 15ms because it pulled from the Cache!
SELECT department_routed, triage_level, AVG(wait_time_minutes) as avg_wait
FROM hospital_db.emergency_analytics.fact_er_visits
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Step 2: Dynamic Compute Scaling (Warehouse Optimization)

-- Let's pretend a massive influx of data is coming in. 
-- Scale your warehouse up from X-Small (1 server) to Large (8 servers) instantly!
ALTER WAREHOUSE compute_wh SET WAREHOUSE_SIZE = 'LARGE';

-- Scale it back down to X-Small now that we are done!
ALTER WAREHOUSE compute_wh SET WAREHOUSE_SIZE = 'XSMALL';

