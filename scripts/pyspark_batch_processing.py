import os
os.environ['SPARK_LOCAL_IP'] = '127.0.0.1'

from pyspark.sql import SparkSession
from pyspark.sql.functions import avg, count

# 1. Initialize Spark Session (The Engine)
spark = SparkSession.builder \
    .appName("HospitalEmergencyETL") \
    .getOrCreate()

print("Spark Session Started Successfully!")

# 2. EXTRACT: Read the batch CSV files
df_patients = spark.read.csv("data/patients_data.csv", header=True, inferSchema=True)
df_visits = spark.read.csv("data/er_visits_data.csv", header=True, inferSchema=True)

# 3. TRANSFORM: Join the tables and calculate insights
# We want to know: How long are patients waiting in each department based on their triage severity?
etl_transformed_df = df_visits.join(df_patients, on="patient_id", how="inner")

aggregated_insights = etl_transformed_df.groupBy("department_routed", "triage_level") \
    .agg(
        avg("wait_time_minutes").alias("avg_wait_time"),
        count("visit_id").alias("total_patients_seen")
    ) \
    .orderBy("department_routed", "triage_level")

# Show a preview of the transformed data in the console
print("\n--- Transformed Data: Avg Wait Times by Department & Triage ---")
aggregated_insights.show()

# 4. LOAD: Save the processed data using Pandas to bypass Windows Hadoop errors
print("\nConverting to Pandas to save locally...")
pandas_df = aggregated_insights.toPandas()

# Saving as CSV is the easiest way to bypass the winutils requirement
pandas_df.to_csv("data/processed_data.csv", index=False)

print("ETL Pipeline completed: Processed data saved to 'data/processed_data.csv'")