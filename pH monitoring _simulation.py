from machine import Pin, ADC
import time

# LED pin
led = Pin(14, Pin.OUT)

# Potentiometer as pH sensor
pot = ADC(26)   # GP26 (ADC0)

# pH thresholds
PH_MIN = 6.5
PH_MAX = 8.5

print("pH Monitoring System - Simulation Mode")

while True:
    # Read potentiometer
    adc_value = pot.read_u16()

    # Map ADC value to pH (0–14)
    pH = (adc_value / 65535) * 14
    pH = round(pH, 2)

    print("Current pH:", pH)

    # Determine pH zone
    if pH < PH_MIN:
        print("Status: ACIDIC - ALERT")
        led.value(1)
        time.sleep(0.2)
        led.value(0)
        time.sleep(0.2)

    elif pH > PH_MAX:
        print("Status: ALKALINE - ALERT")
        led.value(1)
        time.sleep(0.2)
        led.value(0)
        time.sleep(0.2)

    else:
        print("Status: pH NORMAL")
        led.value(0)
        time.sleep(1)

    print("-----------------------")





