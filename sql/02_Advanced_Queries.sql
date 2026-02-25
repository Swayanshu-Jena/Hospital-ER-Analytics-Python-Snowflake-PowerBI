-- Business question-1: "How does an individual patient's wait time compare to the average wait time in their specific department, and who waited the absolute longest in each department?"

-- Step 1: The CTE (Common Table Expression) to gather our base data clearly
WITH PatientWaitTimes AS (
    SELECT 
        v.visit_id,
        p.patient_id,
        p.age,
        v.department_routed,
        v.triage_level,
        v.wait_time_minutes
    FROM hospital_db.emergency_analytics.fact_er_visits v
    JOIN hospital_db.emergency_analytics.dim_patients p 
        ON v.patient_id = p.patient_id
)

-- Step 2: Using Window Functions (AVG OVER and RANK OVER)
SELECT 
    visit_id,
    patient_id,
    department_routed,
    triage_level,
    wait_time_minutes,
    
    -- Window Function 1: Calculate the average wait time specifically for that department
    ROUND(AVG(wait_time_minutes) OVER (PARTITION BY department_routed), 1) AS dept_avg_wait,
    
    -- Window Function 2: Rank patients by who waited the longest within their department
    RANK() OVER (PARTITION BY department_routed ORDER BY wait_time_minutes DESC) AS wait_time_rank
    
FROM PatientWaitTimes
ORDER BY department_routed, wait_time_rank;

-- Business Question 2: "Doctor Workload (Who handles the most critical cases)?"

WITH CriticalCases AS (
    SELECT 
        doctor_id,
        COUNT(visit_id) as critical_patient_count
    FROM hospital_db.emergency_analytics.fact_er_visits
    WHERE triage_level IN (1, 2)
    GROUP BY doctor_id
)
SELECT 
    doctor_id,
    critical_patient_count,
    DENSE_RANK() OVER (ORDER BY critical_patient_count DESC) as workload_rank
FROM CriticalCases
ORDER BY workload_rank;

-- Business Question 3: "Cumulative ER Volume (Running Totals)?"

WITH MonthlyVisits AS (
    SELECT 
        DATE_TRUNC('MONTH', arrival_time) AS visit_month,
        COUNT(visit_id) AS total_visits
    FROM hospital_db.emergency_analytics.fact_er_visits
    GROUP BY 1
)
SELECT 
    CAST(visit_month AS DATE) AS month_start,
    total_visits,
    SUM(total_visits) OVER (ORDER BY visit_month) AS cumulative_hospital_load
FROM MonthlyVisits
ORDER BY visit_month;

