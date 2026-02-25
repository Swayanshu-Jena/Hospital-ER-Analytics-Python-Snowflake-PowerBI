-- 1. Create a dedicated virtual warehouse (the compute engine)
CREATE WAREHOUSE hospital_wh 
WITH WAREHOUSE_SIZE = 'XSMALL' 
AUTO_SUSPEND = 60 
AUTO_RESUME = TRUE;

-- 2. Create the Database (the storage container)
CREATE DATABASE hospital_db;

-- 3. Create a Schema inside the database
CREATE SCHEMA hospital_db.emergency_analytics;

-- 4. Tell Snowflake to use these moving forward
USE WAREHOUSE hospital_wh;
USE DATABASE hospital_db;
USE SCHEMA emergency_analytics;

-- Create the Dimension Table
CREATE TABLE Dim_Patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    blood_group VARCHAR(5),
    pre_existing_condition VARCHAR(50)
);

-- Create the Fact Table
CREATE TABLE Fact_ER_Visits (
    visit_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10),
    doctor_id VARCHAR(10),
    arrival_time TIMESTAMP,
    triage_level INT,
    wait_time_minutes INT,
    department_routed VARCHAR(50),
    FOREIGN KEY (patient_id) REFERENCES Dim_Patients(patient_id)
);

-- Check your patients
SELECT * FROM hospital_db.emergency_analytics.dim_patients LIMIT 10;

-- Check your emergency room visits
SELECT * FROM hospital_db.emergency_analytics.fact_er_visits LIMIT 10;

-- Join them together to see the full picture!
SELECT 
    v.visit_id,
    p.age,
    p.gender,
    v.department_routed,
    v.triage_level,
    v.wait_time_minutes
FROM hospital_db.emergency_analytics.fact_er_visits v
JOIN hospital_db.emergency_analytics.dim_patients p 
  ON v.patient_id = p.patient_id
LIMIT 20;