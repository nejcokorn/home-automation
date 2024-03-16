# Project Objectives
In this home automation project, we aim to address several key concerns often encountered with existing solutions in the market:

**1. Self-management Capability**
- Users should be able to troubleshoot and maintain modules independently. When issues arise, ease of repair or replacement should be a priority.

**2. Cross-Modularity**
- Our solution will seamlessly integrate with various components (e.g., relay modules, input modules, HVAC sensors) regardless of the provider. This flexibility ensures compatibility and accessibility.

**3. Configurability**
- We prioritize an open and user-friendly approach to configuring modules and components. Simplified setup processes enhance usability and adaptability.

**4. Long-Term Support**
- Our system is designed to withstand the test of time, catering to buildings and residences for decades to come. Unlike many market solutions reliant on continuous product support, ours aims for durability and independence from specific providers.

**5. Cloud Optional**
- While cloud-based solutions offer benefits, our system operates efficiently without reliance on cloud infrastructure. This independence safeguards functionality, particularly in scenarios where product providers may cease operations.

**6. Low Technical Knowledge Requirement**
- Our solution is designed to be easily understandable and operable by individuals with varying levels of technical expertise. Intuitive interfaces and straightforward instructions ensure accessibility for most users.

# Key project requirements
- Event driven system for input (switchs, buttons)
- Support for relay modules (shades, light, doors, power socket)
- Data driven events (temperate, wind, humidity, light)
- User friendly overview of the colledted data
- System health checking
- Alarm system

# Hardware
This project uses Raspberry Pi and Arduino Machine Control
- Raspberry Pi in relation along with Node-RED has the main control
- while Arduino Portenta Machine Control is used for extended use of interfaces
## Requirements
- Central logic control 
  - The Raspberry Pi and the I/O control is held in a close distance, preferably in a single electrical cabinet
- Communication with I/O devices over I2C
  - Why I2C and not Modbus rs485 for everything? Simply because I2C is easier to implement, replace, control etc. I2C GPIO expanders can be attached to any relay or input module
- Modbus over RS485 to monitor other devices where I2C is not applicable.
- 
## Components
- 16 channel realy relay boards without any comunication logic attachec, eg. i2c, rs485, can, wifi
  - Devices control where voltage and load is important
  - Example: https://t.ly/4dGbl
- 16 channel input module with integrated I2C (preferably this should be replaced with general purpuse 3-30V optocoupler board) - missing interrupt pin
  - Example: https://t.ly/iOiLO
- 16 channel input module Raspberry Pi
  - https://t.ly/y5IKt
- I2C General purpose input/output (GPIO) Expander
  - PCF8575 is prefered GPIO chip to cover the needs. The market offers several prebuild boards. PCF8575 offers base speed of 400 KHz and 16 channel I/O pins
    - Example: https://t.ly/a7fcQ
  - MCP23017 similar to the pcf chip with the main difference of higher I2C speeds of up to 1.7 MHz and two GPIO block (block A, block B where each has its own interrup pin)
    - Example: https://t.ly/eLE4Y
- Long range I2C Devices - in cases where the device is not held in a central electrical cabinet and the only option is to use i2c we need to make sure the I2C signal is extended
  - I2C extender - https://t.ly/ECtco, https://t.ly/QqwU2, https://t.ly/Jqevm
  - I2C repeter - P82B715
- Sensors
  - Bosch environment sensor BME680 - ensures precise measurements of gas, pressure, humidity, and temperature, with optimized power usage for prolonged stability and air quality monitoring.
  - PT100 or PT1000 to measure temperature where BME680 is not applicable
    - Example: https://t.ly/0FrNc
- I2C additional
  - Connectors: I2C Grove, STEMMA QT
  - I2C addresses: https://t.ly/7jOsZ
- Multiple I2C devices
  - Example: https://t.ly/tvH5P


# Software 
## Node-RED
Preferably use docker for Node-RED, but will have to find a way to expose GPIO pins
```bash
docker run --restart=always --detach --name nodered -p 1880:1880 --device=/dev/i2c-1 nodered/node-red
```

### Packages
- RPi GIPO - https://t.ly/aH2jo
- I2C scanning - https://t.ly/bjiXP
- Node-RED dashboard - https://t.ly/3P1JP
- GPIO extenders - https://t.ly/lA1G-
  - This package could be improved with little extra work (Single component for all pins, single call to extract register data to optimize the flow)

## InfluxDB
InfluxDB is a real-time insights from any time series data with a single, purpose-built database.  
```bash
docker run --restart=always --detach --name influxdb -p 8086:8086 influxdb:2
```

## Grafana
Grafana is an open-source, multi-platform data analytics and interactive data visualization solution.  
Grafana can connect with basically every possible data source, such as InfluxDB.
```bash
docker run --restart=always --detach --name grafana -p 3000:3000 grafana/grafana
```

## EMQX
EMQX is an open-source, highly scalable, and feature-rich MQTT broker designed for IoT and real-time messaging applications.  
It supports up to 100 million concurrent IoT device connections per cluster while maintaining a throughput of 1 million messages per second and a millisecond latency.  
MQTT is used to open communictaion between Raspberry Pi and Arduino
```bash
docker run --restart=always --detach --name emqx -p 1883:1883 -p 8083:8083 -p 8084:8084 -p 8883:8883 -p 18083:18083  emqx:5.5.1
```