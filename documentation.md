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

## circuit design
<img width="735" height="494" alt="image" src="https://github.com/user-attachments/assets/ca35723a-9b5a-44d8-8b83-530722cea55d" />





# **pH Monitoring Module** 

**Author:** Navya VK

## Overview

This module is a part of the aquaponics system and is responsible for monitoring the water pH level to ensure a healthy environment for fish and plants. Maintaining an appropriate pH range is crucial for fish survival and efficient nutrient absorption by plants. This module demonstrates pH monitoring using a simulated setup suitable for testing and academic implementation.

## Working Principle

The system continuously monitors the pH level using a potentiometer, which is used to simulate the behavior of a real pH sensor. The **potentiometer** is connected to the ADC pin of the Raspberry Pi Pico, allowing analog voltage values to be read and converted into corresponding pH values on a scale of 0 to 14.
An **LED** is used as a visual alert indicator to represent abnormal pH conditions instead of using an actual alarm system, making the setup safe and simple for simulation purposes.

## Control Logic

Based on the calculated pH value, the system classifies the water condition as follows:

When the pH value lies between **6.5** and **8.5**, the pH level is considered **NORMAL**

When the pH value falls below **6.5**, the water is ACIDIC, and the **LED alert is activated**

When the pH value rises above **8.5**, the water is ALKALINE, and the **LED alert is activated**

The **LED** blinks to indicate abnormal pH conditions and remains**OFF** when the pH level is within the safe range.

## Simulation and Output

The system provides real-time feedback by displaying the current pH value and its corresponding status (Normal, Acidic, or Alkaline) on the serial console. Adjusting the potentiometer simulates changes in water pH, enabling easy observation of system response and alert indication during testing and demonstration.

## Circuit Design



