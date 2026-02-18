rom machine import Pin, PWM
import time
# Servo setup
servo = PWM(Pin(15))
servo.freq(50)

# Function to rotate servo
def feed_fish():
    print("Feeding Fish...")
    
    # Rotate to 90 degrees
    servo.duty_u16(4900)
    time.sleep(1)
    
    # Return to 0 degrees
    servo.duty_u16(1500)
    time.sleep(1)

# Feeding interval (8 hours in seconds)
feeding_interval = 8 * 60 * 60

while True:
    feed_fish()
    print("Next feeding in 8 hours...")
    time.sleep(feeding_interval)
