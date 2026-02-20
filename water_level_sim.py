from machine import ADC, Pin
import time

# ADC for water level (potentiometer)
water_sensor = ADC(26)  # GP26 = ADC0

# Pump (LED)
pump = Pin(15, Pin.OUT)

while True:
    adc_value = water_sensor.read_u16()  # 0–65535
    water_level = int((adc_value / 65535) * 100)

    if water_level < 30:
        pump.value(1)
        print("Water Level: LOW → Pump ON")

    elif water_level > 70:
        pump.value(0)
        print("Water Level: HIGH → Pump OFF")

    else:
        print("Water Level: NORMAL → Pump HOLD")

    print("Water Level:", water_level, "%")
    print("--------------------------")
    time.sleep(1)
