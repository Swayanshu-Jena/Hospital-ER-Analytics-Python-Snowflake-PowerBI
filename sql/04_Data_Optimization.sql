-- Step 1: Optimize with Data Clustering

-- Apply a Cluster Key to act as our "Partition/Index"
ALTER TABLE hospital_db.emergency_analytics.fact_er_visits 
CLUSTER BY (department_routed, DATE(arrival_time));

-- Check the clustering depth (0 means it is perfectly clustered!)
SELECT system$clustering_depth('hospital_db.emergency_analytics.fact_er_visits');

-- Step 2: Implement Time Travel (Data Recovery)

-- 1. DISASTER: Let's accidentally update every single Cardiology patient to a Triage Level 1!
UPDATE hospital_db.emergency_analytics.fact_er_visits 
SET triage_level = 1 
WHERE department_routed = 'Cardiology';

-- Look at the corrupted data:
SELECT * FROM hospital_db.emergency_analytics.fact_er_visits WHERE department_routed = 'Cardiology' LIMIT 5;

-- 2. RECOVERY: Time Travel to the rescue! 
-- Let's query the table exactly as it looked 2 minutes ago (Offset is in seconds: -60 * 2)
SELECT * FROM hospital_db.emergency_analytics.fact_er_visits AT(OFFSET => -120)
WHERE department_routed = 'Cardiology' 
LIMIT 5;

-- Step 3: Handle Semi-Structured Data (JSON)

-- Create a table for medical device logs using the VARIANT data type for JSON
CREATE TABLE hospital_db.emergency_analytics.device_logs (
    log_id INT AUTOINCREMENT START 1 INCREMENT 1,
    device_data VARIANT
);

-- Insert a mock JSON log from a heart monitor
INSERT INTO hospital_db.emergency_analytics.device_logs (device_data)
SELECT PARSE_JSON('{"device_type": "Heart Monitor", "patient_id": "P00586", "readings": {"heart_rate": 88, "status": "Normal"}}');

-- Query the JSON directly by extracting just the values we want!
SELECT 
    device_data:device_type::STRING AS device,
    device_data:patient_id::STRING AS patient,
    device_data:readings.heart_rate::INT AS heart_rate
FROM hospital_db.emergency_analytics.device_logs;