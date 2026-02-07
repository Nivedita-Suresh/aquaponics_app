#ifndef FISH_FEEDER_H
#define FISH_FEEDER_H

#include <pigpio.h>
#include <string>
#include <vector>
#include <ctime>
#include <thread>
#include <mutex>
#include <atomic>
#include <memory>
#include <fstream>
#include <sstream>
#include <iostream>
#include <chrono>
#include <queue>

class FeedingSchedule {
public:
    int hour;
    int minute;
    int feedDurationMs;
    float feedAmount; // in grams

    FeedingSchedule(int h, int m, int duration, float amount)
        : hour(h), minute(m), feedDurationMs(duration), feedAmount(amount) {}

    bool isTimeToFeed() const {
        time_t now = time(nullptr);
        struct tm* timeinfo = localtime(&now);
        return timeinfo->tm_hour == hour && timeinfo->tm_min == minute;
    }
};

class MotorController {
private:
    unsigned int pinGPIO;
    unsigned int enablePin;
    unsigned int directionPin;
    bool isRunning;
    std::mutex motorMutex;

public:
    MotorController(unsigned int motorPin, unsigned int enablePinNum, unsigned int dirPinNum)
        : pinGPIO(motorPin), enablePin(enablePinNum), directionPin(dirPinNum), isRunning(false) {
        initializePins();
    }

    ~MotorController() {
        stop();
    }

    void initializePins() {
        gpioSetMode(pinGPIO, PI_OUTPUT);
        gpioSetMode(enablePin, PI_OUTPUT);
        gpioSetMode(directionPin, PI_OUTPUT);
    }

    void start(bool clockwise = true) {
        std::lock_guard<std::mutex> lock(motorMutex);
        gpioWrite(directionPin, clockwise ? 1 : 0);
        gpioPWM(enablePin, 255); // Full speed
        gpioWrite(pinGPIO, 1);
        isRunning = true;
    }

    void stop() {
        std::lock_guard<std::mutex> lock(motorMutex);
        gpioPWM(enablePin, 0);
        gpioWrite(pinGPIO, 0);
        isRunning = false;
    }

    void setSpeed(unsigned char speed) {
        std::lock_guard<std::mutex> lock(motorMutex);
        gpioPWM(enablePin, speed); // 0-255
    }

    bool getStatus() const {
        return isRunning;
    }
};

class FoodWeightSensor {
private:
    unsigned int sensorPin;
    float calibrationFactor;
    float zeroOffset;

public:
    FoodWeightSensor(unsigned int pin, float calibFactor = 1.0, float offset = 0.0)
        : sensorPin(pin), calibrationFactor(calibFactor), zeroOffset(offset) {
        gpioSetMode(sensorPin, PI_INPUT);
    }

    float readWeight() const {
        // Simulate reading from ADC (in real scenario, use ADC like MCP3008)
        // This is a placeholder - integrate with actual HX711 or similar
        int rawValue = gpioRead(sensorPin);
        return (rawValue - zeroOffset) * calibrationFactor;
    }

    void calibrate(float knownWeight) {
        float currentReading = readWeight();
        calibrationFactor = knownWeight / currentReading;
    }
};

class TemperatureSensor {
private:
    unsigned int sensorPin;

public:
    TemperatureSensor(unsigned int pin) : sensorPin(pin) {
        gpioSetMode(sensorPin, PI_INPUT);
    }

    float readTemperature() const {
        // Read from DS18B20 or DHT22
        // This is a placeholder
        return 25.0f; // Return temperature in Celsius
    }
};

class FishFeederSystem {
private:
    std::unique_ptr<MotorController> feederMotor;
    std::unique_ptr<FoodWeightSensor> foodSensor;
    std::unique_ptr<TemperatureSensor> tempSensor;
    
    std::vector<FeedingSchedule> feedingSchedules;
    std::atomic<bool> systemRunning;
    std::atomic<bool> emergencyStop;
    
    std::thread monitoringThread;
    std::thread schedulerThread;
    
    std::mutex logMutex;
    std::string logFilePath;
    
    struct FeedingLog {
        time_t timestamp;
        float amountDispensed;
        float temperature;
        bool success;
        std::string notes;
    };
    
    std::queue<FeedingLog> feedingHistory;

public:
    FishFeederSystem(unsigned int motorPin, unsigned int enablePin, unsigned int dirPin,
                     unsigned int foodSensorPin, unsigned int tempSensorPin,
                     const std::string& logPath = "/var/log/fish_feeder.log")
        : feederMotor(std::make_unique<MotorController>(motorPin, enablePin, dirPin)),
          foodSensor(std::make_unique<FoodWeightSensor>(foodSensorPin)),
          tempSensor(std::make_unique<TemperatureSensor>(tempSensorPin)),
          systemRunning(false),
          emergencyStop(false),
          logFilePath(logPath) {
        initializeGPIO();
    }

    ~FishFeederSystem() {
        shutdown();
        gpioTerminate();
    }

    void initializeGPIO() {
        if (gpioInitialise() < 0) {
            std::cerr << "Failed to initialize pigpio" << std::endl;
            exit(1);
        }
    }

    void addFeedingSchedule(int hour, int minute, int durationMs, float amountGrams) {
        feedingSchedules.emplace_back(hour, minute, durationMs, amountGrams);
        logEvent("Schedule added", "Time: " + std::to_string(hour) + ":" + 
                                   std::to_string(minute) + ", Amount: " + 
                                   std::to_string(amountGrams) + "g");
    }

    void removeFeedingSchedule(size_t index) {
        if (index < feedingSchedules.size()) {
            feedingSchedules.erase(feedingSchedules.begin() + index);
        }
    }

    void start() {
        if (systemRunning) return;
        systemRunning = true;
        emergencyStop = false;
        
        schedulerThread = std::thread(&FishFeederSystem::scheduleLoop, this);
        monitoringThread = std::thread(&FishFeederSystem::monitoringLoop, this);
        
        logEvent("System started", "Feeding system is now active");
    }

    void shutdown() {
        systemRunning = false;
        emergencyStop = true;
        
        if (feederMotor) {
            feederMotor->stop();
        }
        
        if (schedulerThread.joinable()) {
            schedulerThread.join();
        }
        if (monitoringThread.joinable()) {
            monitoringThread.join();
        }
        
        logEvent("System shutdown", "Feeding system stopped");
    }

    void manualFeed(float amountGrams, int durationMs) {
        if (emergencyStop) {
            std::cerr << "Emergency stop active. Cannot feed." << std::endl;
            return;
        }

        float initialWeight = foodSensor->readWeight();
        feederMotor->start(true);
        
        std::this_thread::sleep_for(std::chrono::milliseconds(durationMs));
        
        feederMotor->stop();
        float finalWeight = foodSensor->readWeight();
        float dispensed = initialWeight - finalWeight;

        FeedingLog log;
        log.timestamp = time(nullptr);
        log.amountDispensed = dispensed;
        log.temperature = tempSensor->readTemperature();
        log.success = (dispensed >= amountGrams * 0.9); // 90% tolerance
        log.notes = "Manual feed";

        recordFeedingLog(log);
    }

    void triggerEmergencyStop() {
        emergencyStop = true;
        if (feederMotor) {
            feederMotor->stop();
        }
        logEvent("Emergency stop", "System halted due to emergency");
    }

    void resumeAfterEmergency() {
        emergencyStop = false;
        logEvent("System resumed", "Emergency stop cleared");
    }

    float getSystemTemperature() const {
        return tempSensor->readTemperature();
    }

    float getCurrentFoodLevel() const {
        return foodSensor->readWeight();
    }

    std::vector<FeedingSchedule> getSchedules() const {
        return feedingSchedules;
    }

    void printStatus() const {
        std::cout << "\n=== Fish Feeder System Status ===" << std::endl;
        std::cout << "System Running: " << (systemRunning ? "Yes" : "No") << std::endl;
        std::cout << "Emergency Stop: " << (emergencyStop ? "Active" : "Inactive") << std::endl;
        std::cout << "Motor Status: " << (feederMotor->getStatus() ? "Running" : "Stopped") << std::endl;
        std::cout << "Tank Temperature: " << getSystemTemperature() << "°C" << std::endl;
        std::cout << "Food Level: " << getCurrentFoodLevel() << "g" << std::endl;
        std::cout << "Scheduled Feedings: " << feedingSchedules.size() << std::endl;
        std::cout << "================================\n" << std::endl;
    }

private:
    void scheduleLoop() {
        while (systemRunning) {
            for (const auto& schedule : feedingSchedules) {
                if (!emergencyStop && schedule.isTimeToFeed()) {
                    executeFeedingCycle(schedule);
                    std::this_thread::sleep_for(std::chrono::minutes(1)); // Prevent duplicate feeding
                }
            }
            std::this_thread::sleep_for(std::chrono::seconds(10));
        }
    }

    void monitoringLoop() {
        while (systemRunning) {
            float temp = getSystemTemperature();
            float foodLevel = getCurrentFoodLevel();

            // Alert if temperature is abnormal
            if (temp > 30.0f || temp < 18.0f) {
                logEvent("Temperature alert", "Current temp: " + std::to_string(temp) + "°C");
            }

            // Alert if food level is low
            if (foodLevel < 50.0f) {
                logEvent("Low food alert", "Current level: " + std::to_string(foodLevel) + "g");
            }

            std::this_thread::sleep_for(std::chrono::minutes(1));
        }
    }

    void executeFeedingCycle(const FeedingSchedule& schedule) {
        if (emergencyStop) {
            logEvent("Feeding skipped", "Emergency stop active");
            return;
        }

        float initialWeight = foodSensor->readWeight();
        float targetAmount = schedule.feedAmount;
        
        feederMotor->start(true);
        std::this_thread::sleep_for(std::chrono::milliseconds(schedule.feedDurationMs));
        feederMotor->stop();

        float finalWeight = foodSensor->readWeight();
        float dispensed = initialWeight - finalWeight;

        FeedingLog log;
        log.timestamp = time(nullptr);
        log.amountDispensed = dispensed;
        log.temperature = tempSensor->readTemperature();
        log.success = (dispensed >= targetAmount * 0.9); // 90% tolerance
        log.notes = "Scheduled feeding";

        recordFeedingLog(log);
        
        std::string message = "Fed " + std::to_string(dispensed) + "g at " +
                             std::to_string(log.temperature) + "°C";
        logEvent("Feeding completed", message);
    }

    void recordFeedingLog(const FeedingLog& log) {
        std::lock_guard<std::mutex> lock(logMutex);
        feedingHistory.push(log);
        
        std::ofstream logFile(logFilePath, std::ios::app);
        if (logFile.is_open()) {
            logFile << "Time: " << ctime(&log.timestamp)
                   << "Amount: " << log.amountDispensed << "g, "
                   << "Temp: " << log.temperature << "°C, "
                   << "Success: " << (log.success ? "Yes" : "No") << ", "
                   << "Notes: " << log.notes << std::endl;
            logFile.close();
        }
    }

    void logEvent(const std::string& eventType, const std::string& message) {
        std::lock_guard<std::mutex> lock(logMutex);
        
        time_t now = time(nullptr);
        std::string timestamp = ctime(&now);
        timestamp.pop_back(); // Remove trailing newline
        
        std::cout << "[" << timestamp << "] [" << eventType << "] " << message << std::endl;
        
        std::ofstream logFile(logFilePath, std::ios::app);
        if (logFile.is_open()) {
            logFile << "[" << timestamp << "] [" << eventType << "] " << message << std::endl;
            logFile.close();
        }
    }
};

#endif // FISH_FEEDER_H