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
  - [16 Channel Relay board](https://www.amazon.de/-/en/AZDelivery-Optocoupler-Low-Level-Trigger-Compatible/dp/B07N2Z1DWG/ref=sr_1_3?crid=38TPFCCEYWF1A&dib=eyJ2IjoiMSJ9.lkSO2SJV58JioVvzltEqlKBpMkrBRS41Jf9XVfuhAgjkjkoUNaDwTBJIvGninnWSaM26Q9tejJYTXwu-uCALNwZfflFIiRzHKgyUZz9MA6Oh1nUXpJWOuGz9LciqjGYG_0P2hr-t5PYtd8fgdL1Qx4Ou_l3xBzVuHXOhAoS7L5L-9-mBZ11HiB-LKF9lxpIzbKItb8_RAOUnJTFDrGO9t5Cnq4_mquVkQ6YRUDfkd7uzhrW8JiVvH4LMDUdOOUl-JoEG81TD0ygp6xnPi1hpRResajuqbc_-oo5OclQIi1Y.Cne3iue7jhz_DB2IFGjszaWMscRsRrKJvHR-s-reBtQ&dib_tag=se&keywords=relay%2Bboard%2B16%2Bchannel&qid=1711267944&sprefix=relay%2Bboard%2B16%2Bchannel%2Caps%2C92&sr=8-3&th=1)
- 8 channel input module with integrated I2C (preferably this should be replaced with general purpuse 5-30V optocoupler board) - missing interrupt pin
  - [8 Channel Optocoupler 24 V to 3.3 V](https://www.amazon.de/Optocoupler-Insulation-8-Channel-Voltage-Converter/dp/B07VMFMZFH/ref=sr_1_15_sspa?crid=21YAOHXWP6X9F&dib=eyJ2IjoiMSJ9.efjjBxAHDpQljUfo-yQLz4VFUwuBc9OPz5FLPoytAQpjqGPTFkaWs_9LRnorRIXqoEkJtZmAyomWhwB9OYuLETJf8YTWDYLnDcTqPCnJdyrBikda5wASJfe7NKwSJT68FupWnnkTjKs-yONDo9Fa65-KMr475I97rk-kbq6C9FEXUPylwuT0fkya8_-3kHCUmBta3Mdt6Ryp-1e_7nYNVwZzrIcbO-YcjbmaEJQy2tNwitVm6ri2l9QkAfN937yCFiTyoqx9yIfokW-oPH_PZga282nBD8WBKUIyoIbo-yM.XAiYvGzy-51kfNc9scWabzduR7hJtxFWbp2Ej4iGid0&dib_tag=se&keywords=input+modul+optocoupler+16+channel+5-24v&qid=1711268114&sprefix=input+modul+optocoupler+16+channel+5-24v%2Caps%2C82&sr=8-15-spons&sp_csd=d2lkZ2V0TmFtZT1zcF9tdGY&psc=1)
- [16 LV Universal Inputs 8-Layer Stackable HAT for Raspberry Pi](https://thepihut.com/products/16-universal-inputs-8-layer-stackable-card-for-raspberry-pi)
- I2C General purpose input/output (GPIO) Expander
  - PCF8575 is prefered GPIO chip to cover the needs. The market offers several prebuild boards. PCF8575 offers base speed of 400 KHz and 16 channel I/O pins
    - [Adafruit PCF8575 I2C 16 GPIO Expander](https://www.adafruit.com/product/5611)
  - MCP23017 similar to the pcf chip with the main difference of higher I2C speeds of up to 1.7 MHz and two GPIO block (block A, block B where each has its own interrup pin)
    - [Adafruit MCP23017 I2C GPIO Expander](https://www.adafruit.com/product/5346)
- Long range I2C Devices - in cases where the device is not held in a central electrical cabinet and the only option is to use i2c we need to make sure the I2C signal is extended
  - I2C extender
    - [Adafruit LTC4311 I2C Extender / Active Terminator](https://www.adafruit.com/product/4756)
    - [Qwiic Differential I2C Breakout](https://kamami.pl/en/retired-products/571689-qwiic-differential-i2c-breakout-module-with-i2c-pca9615-differential-transceiver-bob-14589.html) (I2C over UTP)
    - [Lead expander - 8-channel - with I2C multiplexer - PCA9548](https://botland.store/8-bit-multiplexers/22391-lead-expander-8-channel-with-i2c-multiplexer-pca9548-stemma-qt-qwiic-adafruit-5626.html)
  - I2C repeter
    - [Active I2C Long Cable Extender P82B715 Module](https://sensorsandprobes.com/es/products/active-i2c-long-cable-extender-p82b715-module)
- Sensors
  - Bosch environment sensor - ensures precise measurements of gas, pressure, humidity, and temperature, with optimized power usage for prolonged stability and air quality monitoring.
    - [BME688](https://www.amazon.de/-/en/Sxhlseller-Environmental-Function-Temperature-Raspberry/dp/B0C62GTJZS/ref=sr_1_27?crid=2AAWCGU3QY37U&dib=eyJ2IjoiMSJ9.MumA7AL-ZtgXHUDlfkrGq0QTDzZKdMLgmsv7eHNKYdroCY2k7Z-ZVL7j4XM2PeTAs2nQ9-ocJfrpXTwxX46FQsxYoVNUTNhUJ67hqcwlxY8Hy2bigTGL-rNDYivv5Yt3mRkp4P7Tlt2jvCJYhWomGre7nM-YxcpILszhlCMviGAu86WRu941MbY9nLrNAsjfO9PcfWBehizTSQWiJxgJEy-xEYd54lT5SKBCnc_NBxVXXGRW61Y1LQApyGhUihRXD-knIKFGWJltF47ULSpIkANhuLWlWDpqX_Sbs5hmU-o.HHoIKQAtHTBC-lpP_gnRkGiwnmR_7zPIn2gVZzzlGPo&dib_tag=se&keywords=bosch+bme688&qid=1711269525&sprefix=bosch+bme688%2Caps%2C87&sr=8-27)
    -  [BME680](https://www.amazon.de/-/en/CJMCU-680-Pressure-Temperature-Humidity-Development/dp/B07G16X8YH/ref=sr_1_6?crid=2AAWCGU3QY37U&dib=eyJ2IjoiMSJ9.MumA7AL-ZtgXHUDlfkrGq0QTDzZKdMLgmsv7eHNKYdroCY2k7Z-ZVL7j4XM2PeTAs2nQ9-ocJfrpXTwxX46FQsxYoVNUTNhUJ67hqcwlxY8Hy2bigTGL-rNDYivv5Yt3mRkp4P7Tlt2jvCJYhWomGre7nM-YxcpILszhlCMviGAu86WRu941MbY9nLrNAsjfO9PcfWBehizTSQWiJxgJEy-xEYd54lT5SKBCnc_NBxVXXGRW61Y1LQApyGhUihRXD-knIKFGWJltF47ULSpIkANhuLWlWDpqX_Sbs5hmU-o.HHoIKQAtHTBC-lpP_gnRkGiwnmR_7zPIn2gVZzzlGPo&dib_tag=se&keywords=bosch+bme688&qid=1711269525&sprefix=bosch+bme688%2Caps%2C87&sr=8-6)
  - PT100 or PT1000 to measure temperature where BME680 is not applicable
    - [RS485 with 8 channel PT100](https://www.aliexpress.com/item/1005006295880104.html?src=google&aff_fcid=45c32bcb41644cfc831edd66dc488c91-1711269742536-00959-UneMJZVf&aff_fsk=UneMJZVf&aff_platform=aaf&sk=UneMJZVf&aff_trace_key=45c32bcb41644cfc831edd66dc488c91-1711269742536-00959-UneMJZVf&terminal_id=0b359a39cd9a4e8ca5742cbec62e2981&afSmartRedirect=y)
  - [DS18B20 1-Wire](https://www.aliexpress.com/item/1005005973956237.html?spm=a2g0o.productlist.main.3.3233q0Pxq0PxCF&algo_pvid=2fa86c7b-143e-49d0-9849-ea5b5fc4e1a3&algo_exp_id=2fa86c7b-143e-49d0-9849-ea5b5fc4e1a3-1&pdp_npi=4%40dis%21EUR%212.41%211.40%21%21%2118.50%2110.73%21%402101fb1217112713194911899ea8c5%2112000035223481334%21sea%21DE%21177306676%21&curPageLogUid=IxtUq6hUcj0F&utparam-url=scene%3Asearch%7Cquery_from%3A) (Prefered for temperature only)
- I2C additional
  - Connectors: [I2C Grove, STEMMA QT](https://www.adafruit.com/product/4528)
  - [I2C addresses](https://learn.adafruit.com/i2c-addresses/the-list)

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