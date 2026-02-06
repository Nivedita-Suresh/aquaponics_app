# **Water Level Monitoring & Pump Control Module**

**Author:** NiveditaSuresh 

## Overview
This module is a component of the aquaponics system and is responsible for automatically monitoring and maintaining the water level. Proper water level control is essential to ensure the health of both plants and fish while preventing overflow or water shortages.

## Working Principle
The system continuously monitors the water level using a **potentiometer**, which is used to simulate a real water level sensor. The potentiometer is connected to the ADC pin of the Raspberry Pi Pico, allowing analog values to be read and converted into a percentage-based water level (0–100%).An **LED** is used to simulate the pump operation instead of an actual relay and pump for safe testing and demonstration purposes.

## Control Logic
Based on the measured water level, the pump operation is controlled automatically:
- When the water level falls below **30%**, the pump is turned **ON**
- When the water level rises above **70%**, the pump is turned **OFF**
- For water levels between **30% and 70%**, the pump remains in a **HOLD** state


## Simulation and Output
The system provides real-time feedback by printing the current water level and pump status to the console. Adjusting the potentiometer simulates changes in water level, allowing easy observation of pump behavior during testing.


<img width="735" height="494" alt="image" src="https://github.com/user-attachments/assets/ca35723a-9b5a-44d8-8b83-530722cea55d" />
