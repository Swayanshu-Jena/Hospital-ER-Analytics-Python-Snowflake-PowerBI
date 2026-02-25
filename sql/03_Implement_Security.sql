-- STEP 1: Implementing RBAC (Role-Based Access Control)
-- Create the specific roles
CREATE ROLE IF NOT EXISTS er_doctor;
CREATE ROLE IF NOT EXISTS data_analyst;

-- Grant basic access to the database and schema for both roles
GRANT USAGE ON DATABASE hospital_db TO ROLE er_doctor;
GRANT USAGE ON SCHEMA hospital_db.emergency_analytics TO ROLE er_doctor;
GRANT USAGE ON DATABASE hospital_db TO ROLE data_analyst;
GRANT USAGE ON SCHEMA hospital_db.emergency_analytics TO ROLE data_analyst;

-- Grant specific privileges (Doctors can edit visits, Analysts can only read)
GRANT SELECT, INSERT, UPDATE ON hospital_db.emergency_analytics.fact_er_visits TO ROLE er_doctor;
GRANT SELECT ON hospital_db.emergency_analytics.fact_er_visits TO ROLE data_analyst;
GRANT SELECT ON hospital_db.emergency_analytics.dim_patients TO ROLE data_analyst;

-- Grant the analyst role to yourself so you can test it
GRANT ROLE data_analyst TO USER SWAYANSHUJENA;


-- STEP 2 (ALTERNATIVE): Implement Security via Secure Views
-- Create a secure virtual window over the patients table
CREATE OR REPLACE SECURE VIEW hospital_db.emergency_analytics.secure_dim_patients AS
SELECT 
    patient_id,
    age,
    gender,
    -- Here is the masking logic built directly into the view:
    CASE 
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'ER_DOCTOR') THEN pre_existing_condition
        ELSE '*** MASKED ***'
    END AS pre_existing_condition
FROM hospital_db.emergency_analytics.dim_patients;

-- Revoke the analyst's direct access to the raw table so they can't cheat
REVOKE SELECT ON hospital_db.emergency_analytics.dim_patients FROM ROLE data_analyst;

-- Grant the analyst access to our new Secure View instead
GRANT SELECT ON hospital_db.emergency_analytics.secure_dim_patients TO ROLE data_analyst;


-- STEP 3: Test the Security!
-- Let's pretend we are the data analyst querying the new secure view:
USE ROLE data_analyst;

-- Run this! You should see '*** MASKED ***' in the condition column.
SELECT * FROM hospital_db.emergency_analytics.secure_dim_patients LIMIT 5;


-- STEP 4: Switch Back to Admin!
-- (Crucial: Run this so you regain your full admin privileges)
USE ROLE ACCOUNTADMIN;