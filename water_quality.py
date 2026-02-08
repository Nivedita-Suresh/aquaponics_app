import machine
import onewire, ds18x20
import time

# =========================
# PIN SETUP
# =========================

# DS18B20 Temperature Sensor
ds_pin = machine.Pin(22)
ds_sensor = ds18x20.DS18X20(onewire.OneWire(ds_pin))
roms = ds_sensor.scan()

# Potentiometers (ADC)
ph_adc = machine.ADC(26)       # pH sensor simulation
level_adc = machine.ADC(27)    # Water level simulation

# LEDs
alert_led = machine.Pin(15, machine.Pin.OUT)   # Red LED
ok_led = machine.Pin(14, machine.Pin.OUT)      # Green LED

# =========================
# THRESHOLDS
# =========================

TEMP_LOW = 30.0
TEMP_HIGH = 35.0

PH_LOW = 6.5
PH_HIGH = 8.5

LEVEL_LOW = 20     # % (low water)
LEVEL_HIGH = 80    # % (high water)

# =========================
# FUNCTIONS
# =========================

def read_temperature():
    ds_sensor.convert_temp()
    time.sleep_ms(750)
    for rom in roms:
        return round(ds_sensor.read_temp(rom), 2)

def read_ph():
    raw = ph_adc.read_u16()
    voltage = raw * 3.3 / 65535
    ph = 3.5 * voltage        # Wokwi pH simulation formula
    return round(ph, 2)

def read_water_level():
    raw = level_adc.read_u16()
    level_percent = (raw / 65535) * 100
    return round(level_percent, 1)

# =========================
# MAIN LOOP
# =========================

print("=== Water Monitoring System Started ===")

while True:
    temperature = read_temperature()
    ph_value = read_ph()
    water_level = read_water_level()

    alert = False

    # Check temperature
    if temperature < TEMP_LOW or temperature > TEMP_HIGH:
        alert = True

    # Check pH
    if ph_value < PH_LOW or ph_value > PH_HIGH:
        alert = True

    # Check water level
    if water_level < LEVEL_LOW or water_level > LEVEL_HIGH:
        alert = True

    # LED Logic
    alert_led.value(alert)
    ok_led.value(not alert)

    # =========================
    # DISPLAY ALL DATA TOGETHER
    # =========================
    print("\n----------------------------")
    print(f"Water Temperature : {temperature} °C")
    print(f"Water pH          : {ph_value}")
    print(f"Water Level       : {water_level} %")
    print("System Status     :", "ALERT ⚠️" if alert else "NORMAL ✅")
    print("----------------------------")

    time.sleep(2)
