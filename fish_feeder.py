import RPi.GPIO as GPIO
import time
from datetime import datetime

# ============================================
# Configuration
# ============================================
SERVO_PIN = 18
FEEDING_TIMES = ["08:00", "14:00", "20:00"]  # 3 feeds per day
PWM_FREQUENCY = 50  # Hz

# ============================================
# Servo Control Functions
# ============================================
def initialize_servo():
    """Initialize GPIO and servo PWM"""
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(SERVO_PIN, GPIO.OUT)
    pwm = GPIO.PWM(SERVO_PIN, PWM_FREQUENCY)
    pwm.start(0)
    return pwm

def set_servo_angle(pwm, angle):
    """Set servo to specific angle (0-180 degrees)"""
    # Convert angle to duty cycle (SG90 servo)
    duty_cycle = 2.5 + (angle / 18.0)
    pwm.ChangeDutyCycle(duty_cycle)

def feed_fish(pwm, feed_duration=2):
    """Execute feeding sequence"""
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Feeding fish...")
    
    # Open feeder (rotate to 90 degrees)
    set_servo_angle(pwm, 90)
    time.sleep(feed_duration)
    
    # Close feeder (rotate back to 0 degrees)
    set_servo_angle(pwm, 0)
    time.sleep(1)
    
    # Stop PWM to prevent servo heating
    pwm.ChangeDutyCycle(0)
    print("[{}] Feeding complete.".format(datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

# ============================================
# Main Loop
# ============================================
def main():
    """Main feeding schedule loop"""
    pwm = initialize_servo()
    last_feed_time = None
    
    try:
        print("Fish feeder started. Feeding times:", FEEDING_TIMES)
        
        while True:
            current_time = datetime.now().strftime("%H:%M")
            
            # Check if it's feeding time
            if current_time in FEEDING_TIMES and last_feed_time != current_time:
                feed_fish(pwm, feed_duration=2)
                last_feed_time = current_time
            
            time.sleep(1)
    
    except KeyboardInterrupt:
        print("\nShutting down gracefully...")
    
    finally:
        pwm.stop()
        GPIO.cleanup()
        print("GPIO cleaned up. Goodbye!")

if __name__ == "__main__":
    main()