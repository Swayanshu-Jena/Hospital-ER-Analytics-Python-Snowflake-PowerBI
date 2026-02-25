import pandas as pd
import random
from datetime import datetime, timedelta

# Configuration
NUM_PATIENTS = 1000
NUM_VISITS = 5000
START_DATE = datetime(2025, 1, 1)

print("Starting data generation...")

# 1. Generate patients_data
print("Generating patients_data...")
patient_ids = [f"P{str(i).zfill(5)}" for i in range(1, NUM_PATIENTS + 1)]
genders = ['Male', 'Female', 'Other']
blood_groups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
conditions = ['None', 'Hypertension', 'Diabetes', 'Asthma', 'Heart Disease', 'None', 'None'] # Weighted 'None'

patients_data = {
    'patient_id': patient_ids,
    'age': [random.randint(1, 95) for _ in range(NUM_PATIENTS)],
    'gender': [random.choice(genders) for _ in range(NUM_PATIENTS)],
    'blood_group': [random.choice(blood_groups) for _ in range(NUM_PATIENTS)],
    'pre_existing_condition': [random.choice(conditions) for _ in range(NUM_PATIENTS)]
}

df_patients = pd.DataFrame(patients_data)
df_patients.to_csv('patients_data.csv', index=False)
print("Saved patients_data.csv")

# 2. Generate er_visits_data
print("Generating er_visits_data...")
visit_ids = [f"V{str(i).zfill(6)}" for i in range(1, NUM_VISITS + 1)]
doctor_ids = [f"D{str(i).zfill(3)}" for i in range(1, 21)] # 20 Doctors
departments = ['Trauma', 'Pediatrics', 'General ER', 'Cardiology', 'Orthopedics']

visits_data = []
for visit_id in visit_ids:
    patient_id = random.choice(patient_ids)
    doctor_id = random.choice(doctor_ids)
    
    # Random arrival time over the last year
    random_days = random.randint(0, 365)
    random_minutes = random.randint(0, 24 * 60)
    arrival_time = START_DATE + timedelta(days=random_days, minutes=random_minutes)
    
    # Triage Level: 1 (Resuscitation) to 5 (Non-Urgent)
    triage_level = random.choices([1, 2, 3, 4, 5], weights=[5, 15, 40, 30, 10])[0]
    
    # Logic: More critical triage = shorter wait time
    if triage_level == 1:
        wait_time = random.randint(0, 5) # 0-5 mins
    elif triage_level == 2:
        wait_time = random.randint(5, 15)
    elif triage_level == 3:
        wait_time = random.randint(15, 60)
    else:
        wait_time = random.randint(30, 240)
        
    department = random.choice(departments)
    
    visits_data.append([
        visit_id, patient_id, doctor_id, arrival_time.strftime('%Y-%m-%d %H:%M:%S'), 
        triage_level, wait_time, department
    ])

df_visits = pd.DataFrame(visits_data, columns=[
    'visit_id', 'patient_id', 'doctor_id', 'arrival_time', 
    'triage_level', 'wait_time_minutes', 'department_routed'
])
df_visits.to_csv('er_visits_data.csv', index=False)
print("Saved er_visits_data.csv")

print("Data generation complete! You now have two CSV files.")