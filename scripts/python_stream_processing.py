import time
import random
import datetime

print("Initializing Pure Python Live Vitals Stream...")
print("Listening for critical patient vitals...")
print("Press Ctrl+C to stop the stream.\n")
print("-" * 50)
print(f"{'TIMESTAMP':<25} | {'PATIENT_ID':<12} | {'HEART_RATE'}")
print("-" * 50)

try:
    # 1. Start the infinite loop to simulate a live data stream
    while True:
        # 2. EXTRACT: Generate a mock reading (1 per second)
        current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        patient_id = f"P00{random.randint(100, 200)}"
        heart_rate = random.randint(60, 120)
        
        # 3. TRANSFORM: Apply real-time business logic (Filter for alerts)
        if heart_rate > 100:
            # 4. LOAD: Output the critical alert immediately
            print(f"{current_time:<25} | {patient_id:<12} | {heart_rate} (CRITICAL ALERT)")
        
        # Pause for exactly 1 second before receiving the next reading
        time.sleep(1)

except KeyboardInterrupt:
    print("\n" + "-" * 50)
    print("Stream manually terminated by user.")
    print("Live processing complete.")