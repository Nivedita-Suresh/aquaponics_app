import machine
import onewire, ds18x20
import time

# --- Hardware Setup ---
# Data wire is on GP22
ds_pin = machine.Pin(22)
# LED for the Alert on GP15
alert_led = machine.Pin(15, machine.Pin.OUT)

# Initialize the DS18B20 sensor
ds_sensor = ds18x20.DS18X20(onewire.OneWire(ds_pin))

# Scan for sensors on the bus
roms = ds_sensor.scan()
print('Found DS18B20 devices:', roms)

# Configuration
THRESHOLDUL = 35.0  # Alert if temp goes above 35°C
THRESHOLDLL=30.0
print("--- Starting Water Monitor ---")

while True:
    # 1. Start a temperature conversion
    ds_sensor.convert_temp()
    
    # 2. Wait for conversion (750ms is standard for 12-bit)
    time.sleep_ms(750)
    
    # 3. Read the temperature for each sensor found
    for rom in roms:
        temp = ds_sensor.read_temp(rom)
        
        # Round the temperature for display
        temp = round(temp, 2)
        
        # 4. Logical Check & Output
        if temp >= THRESHOLDUL:
            alert_led.value(1)  # Turn LED ON
            status = " [!! ALERT !!]"
        elif temp <= THRESHOLDLL:
            alert_led.value(1)  # Turn LED ON
            status = " [!! ALERT !!]"
        else:
            alert_led.value(0)  # Turn LED OFF
            status = " [OK]"
        print(f"Water Temp: {temp}°C {status}")

    # Small delay before next loop
    time.sleep(1)
