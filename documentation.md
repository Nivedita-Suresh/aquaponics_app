# **1. Water Level Monitoring & Pump Control Module**

**Author:** Nivedita Suresh 

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










# **2. Water pH Monitoring Module** 

**Author:** Navya VK

## Overview

This module is a part of the aquaponics system and is responsible for monitoring the water pH level to ensure a healthy environment for fish and plants. Maintaining an appropriate pH range is crucial for fish survival and efficient nutrient absorption by plants. This module demonstrates pH monitoring using a simulated setup suitable for testing and academic implementation.

## Working Principle

The system continuously monitors the pH level using a potentiometer, which is used to simulate the behavior of a real pH sensor. The **potentiometer** is connected to the ADC pin of the Raspberry Pi Pico, allowing analog voltage values to be read and converted into corresponding pH values on a scale of 0 to 14.
An **LED** is used as a visual alert indicator to represent abnormal pH conditions instead of using an actual alarm system, making the setup safe and simple for simulation purposes.

## Control Logic

Based on the calculated pH value, the system classifies the water condition as follows:

- When the pH value lies between **6.5** and **8.5**, the pH level is considered **NORMAL**

- When the pH value falls below **6.5**, the water is ACIDIC, and the **LED alert is activated**

- When the pH value rises above **8.5**, the water is ALKALINE, and the **LED alert is activated**

- The **LED** blinks to indicate abnormal pH conditions and remains **OFF** when the pH level is within the safe range.

## Simulation and Output

The system provides real-time feedback by displaying the current pH value and its corresponding status (Normal, Acidic, or Alkaline) on the serial console. Adjusting the potentiometer simulates changes in water pH, enabling easy observation of system response and alert indication during testing and demonstration.

## Circuit Design
<img width="735" height="494" alt="pH Monitoring Pinout Diagram" src="https://github.com/user-attachments/assets/9f2c1e84-71a6-4b92-bd6a-2d91a8e4c712" />





# **3. Water Temperature Monitoring & Alert Module**

**Author:** Nikhil H  

---

### Overview  
The Water Temperature Monitoring & Alert Module is a critical part of the aquaponics automation system. It continuously measures the water temperature in real time to ensure a healthy environment for both fish and plants. Maintaining an optimal temperature range is essential for fish metabolism and efficient nutrient absorption in plants.  

The module also includes an automated alert mechanism that warns the user whenever the temperature exceeds safe limits.

---

### Working Principle  
This system uses the **DS18B20 digital temperature sensor** interfaced with the **Raspberry Pi Pico**. Unlike analog temperature sensors, the DS18B20 operates using the **1-Wire communication protocol**, enabling accurate digital temperature readings with minimal wiring.

- **Data Acquisition:**  
  The Pico reads temperature values from the DS18B20 through a single data pin (**GP22**). A **4.7 kΩ pull-up resistor** is used to maintain signal stability and ensure reliable communication.

- **Visual Alert Mechanism:**  
  An LED is included in the circuit as a **Critical Temperature Indicator**, simulating an automated cooling trigger or manual alarm system.

---

### Control Logic  
The firmware continuously polls the sensor and compares the temperature against a defined threshold:

- **Normal State:**  
  If the temperature remains **between 30°C and 25°C**, the system stays in monitoring mode and the Alert LED remains **OFF**.

- **Alert State:**  
  If the temperature reaches either **above 30°C** or **below 25°C** , the system activates a high-priority warning. The LED turns **ON**, and a warning message is printed to the serial console.

- **Error Handling:**  
  The code verifies whether the sensor is properly connected. If no ROM address is detected, the system reports a **"Device Disconnected"** error.

---

### Simulation and Output  
The module is simulated using **Wokwi** with **MicroPython**. Within the simulation:

- The user can manually adjust the DS18B20 temperature value by clicking and sliding the sensor control.
- The Serial Console displays continuous real-time temperature readings in **degrees Celsius (°C)**.
- The LED provides immediate visual feedback when the temperature exceeds the critical threshold.

---

### Circuit Design  
<img width="735" height="494" alt="Screenshot 2026-02-07 164303" src="https://github.com/user-attachments/assets/c642e0e2-8c6f-438f-86a3-2d345c7f8cc8" />

# **4. Pump Logic**

**Author:** Nivedita Suresh

### Overview
This aquaponics system uses a **single submersible water pump** to circulate water between the fish tank and the grow beds. The pump is placed inside the fish tank and is responsible for lifting nutrient-rich water to the grow beds, while the return flow to the tank occurs naturally through **gravity-based drainage**. This simple and efficient circulation mechanism ensures continuous nutrient delivery to plants and maintains a healthy aquatic environment for the fish.

### Pump Operation
For the current small-scale setup (one fish tank with one or two grow beds and a minimal fish load), the pump operates in a **continuous ON mode**. Continuous circulation provides:
- Stable water levels in the fish tank
- Consistent nutrient supply to plant roots
- Improved oxygenation of water
- Reduced stress on fish due to sudden flow changes

An optional enhancement to this approach is a **timed flood-and-drain cycle**, where the pump operates for a fixed duration (e.g., ON for a few minutes and OFF for a few minutes). This mode can improve root aeration and reduce power consumption, but it is not strictly required for the current system scale.

### Use of a Single Pump
Only **one pump** is used in the system due to the following reasons:
- Gravity efficiently returns water from the grow beds back to the fish tank
- Additional pumps for drainage are unnecessary and increase system complexity
- A single pump is sufficient to handle the low flow-rate requirements of a small aquaponics setup
- Fewer components reduce power consumption, cost, and maintenance effort

This design choice improves overall system reliability while keeping the architecture simple and easy to manage.

### Complexity Avoidance and Design Justification
Advanced aquaponics systems often use multiple pumps, solenoid valves, and closed-loop control based on real-time sensor feedback. However, such complexity was intentionally avoided in this project because:
- The system operates at a very small scale
- The risk of overflow or dry-run conditions is minimal
- Over-automation increases failure points and debugging difficulty
- Simplicity enhances long-term stability and ease of use


### Summary
The pump logic prioritizes **simplicity, reliability, and energy efficiency**. By using a single continuously operating pump and gravity-assisted drainage, the system achieves effective water circulation without unnecessary complexity. Sensor data is leveraged for monitoring and alerts rather than direct actuation, making the design well-suited for small-scale aquaponics applications and future scalability.

# **5. Integrated Water Monitoring Module**

The individual modules for water temperature, pH level, and water level monitoring were successfully integrated into a single program running on the Raspberry Pi. This integration allows all sensor data to be collected and processed together, ensuring synchronized readings and simpler system management.

The combined module displays water temperature, pH value, water level condition, and overall system status through a serial/terminal output. This confirms correct sensor operation and system stability after integration.

As a next stage, the integrated sensor data will be sent to a mobile application for real-time remote monitoring. This will enable users to track water temperature, pH level, and water level directly from their phones, forming the basis for future IoT-based control and alert features.

<img width="754" height="547" alt="image" src="https://github.com/user-attachments/assets/44a43a8c-f42c-4cd1-b724-08713bcc29f7" />


