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
- Event-driven system for input (switches, buttons)
- Support for relay modules (shades, light, doors, power socket)
- Data-driven events (temperature, wind, humidity, light)
- User-friendly overview of the collected data
- System health checking
- Alarm system

# Hardware
This project uses Raspberry Pi
- Raspberry Pi 4/5 with Node-RED or Home Automation, which controls the devices locally over CAN2.0
## Requirements
- Central logic control 
  - The Raspberry Pi and the I/O control is held in a close proximity, preferably in a single electrical cabinet
- Communication with I/O devices over CAN.
  - Modbus over RS-485 to monitor other devices/sensors where CAN is not applicable.

## Components
- 3 Layer custom device
  - Relay boards without any communication logic attached, eg, I2C, RS-485, CAN, etc.
  - Input board with MCU to control inputs and outputs
  - Communication board using CAN 2.0
- Sensors
  - Bosch environment sensor - ensures precise measurements of gas, pressure, humidity, and temperature, with optimized power usage for prolonged stability and air quality monitoring.
    - [BME688](https://www.amazon.de/-/en/Sxhlseller-Environmental-Function-Temperature-Raspberry/dp/B0C62GTJZS/ref=sr_1_27?crid=2AAWCGU3QY37U&dib=eyJ2IjoiMSJ9.MumA7AL-ZtgXHUDlfkrGq0QTDzZKdMLgmsv7eHNKYdroCY2k7Z-ZVL7j4XM2PeTAs2nQ9-ocJfrpXTwxX46FQsxYoVNUTNhUJ67hqcwlxY8Hy2bigTGL-rNDYivv5Yt3mRkp4P7Tlt2jvCJYhWomGre7nM-YxcpILszhlCMviGAu86WRu941MbY9nLrNAsjfO9PcfWBehizTSQWiJxgJEy-xEYd54lT5SKBCnc_NBxVXXGRW61Y1LQApyGhUihRXD-knIKFGWJltF47ULSpIkANhuLWlWDpqX_Sbs5hmU-o.HHoIKQAtHTBC-lpP_gnRkGiwnmR_7zPIn2gVZzzlGPo&dib_tag=se&keywords=bosch+bme688&qid=1711269525&sprefix=bosch+bme688%2Caps%2C87&sr=8-27)
    -  [BME680](https://www.amazon.de/-/en/CJMCU-680-Pressure-Temperature-Humidity-Development/dp/B07G16X8YH/ref=sr_1_6?crid=2AAWCGU3QY37U&dib=eyJ2IjoiMSJ9.MumA7AL-ZtgXHUDlfkrGq0QTDzZKdMLgmsv7eHNKYdroCY2k7Z-ZVL7j4XM2PeTAs2nQ9-ocJfrpXTwxX46FQsxYoVNUTNhUJ67hqcwlxY8Hy2bigTGL-rNDYivv5Yt3mRkp4P7Tlt2jvCJYhWomGre7nM-YxcpILszhlCMviGAu86WRu941MbY9nLrNAsjfO9PcfWBehizTSQWiJxgJEy-xEYd54lT5SKBCnc_NBxVXXGRW61Y1LQApyGhUihRXD-knIKFGWJltF47ULSpIkANhuLWlWDpqX_Sbs5hmU-o.HHoIKQAtHTBC-lpP_gnRkGiwnmR_7zPIn2gVZzzlGPo&dib_tag=se&keywords=bosch+bme688&qid=1711269525&sprefix=bosch+bme688%2Caps%2C87&sr=8-6)
  - PT100 or PT1000 to measure temperature where BME680 is not applicable
    - [RS485 with 8 channel PT100](https://www.aliexpress.com/item/1005006295880104.html?src=google&aff_fcid=45c32bcb41644cfc831edd66dc488c91-1711269742536-00959-UneMJZVf&aff_fsk=UneMJZVf&aff_platform=aaf&sk=UneMJZVf&aff_trace_key=45c32bcb41644cfc831edd66dc488c91-1711269742536-00959-UneMJZVf&terminal_id=0b359a39cd9a4e8ca5742cbec62e2981&afSmartRedirect=y)
  - [DS18B20 1-Wire](https://www.aliexpress.com/item/1005005973956237.html?spm=a2g0o.productlist.main.3.3233q0Pxq0PxCF&algo_pvid=2fa86c7b-143e-49d0-9849-ea5b5fc4e1a3&algo_exp_id=2fa86c7b-143e-49d0-9849-ea5b5fc4e1a3-1&pdp_npi=4%40dis%21EUR%212.41%211.40%21%21%2118.50%2110.73%21%402101fb1217112713194911899ea8c5%2112000035223481334%21sea%21DE%21177306676%21&curPageLogUid=IxtUq6hUcj0F&utparam-url=scene%3Asearch%7Cquery_from%3A) (Prefered for temperature only)
- 1-Wire
  - [Setup 1-Wire on Raspberry Pi](https://pinout.xyz/pinout/1_wire)
  - [Temperature sensor DS18B20](https://www.amazon.de/-/en/AZDelivery-Stainless-Temperature-Waterproof-Compatible/dp/B07KNQJ3D7/ref=sr_1_6?crid=2HG1SMT39XVDG&dib=eyJ2IjoiMSJ9.XdeEgp9CgEREBq9z3rEwyn-u6YslVqoOq-Z5UQ0Qovi9HH8RfHxUao7jpj9nLwpDnhxn8jd7CN50pNPFg7KcDdG3Fpn7IUrHUslzcQ-A1Iv0yE5Aa0lGFjKBPjUOog2cFEhqJ9UC5GIQnsgFED0CohKROIUMluZNNAV9y7HrlJYq1m086jIBYok0WaEJTPvmtswWxXSZsJ0FYw_wX6Urfy4EEtOf17s04_98B1URFdRJXdGOQJO8XvomMkd0ibz2khlk_Np9pyUOa83OmDlFN1iBdiygE-RBFRxMzeW_FvE._u0CrHM2dPLWBblmLUgHRFGawB1Co3x2vFj-qZNbD8g&dib_tag=se&keywords=DS18B20&qid=1711287881&sprefix=ds18b20%2Caps%2C105&sr=8-6&th=1)
  - [DS18B20 on RJ45](https://www.unipi.technology/1-wire-temperature-sensor-10-m-p577)
  - [RJ45 hub](https://www.aliexpress.com/item/4000201139432.html?spm=a2g0o.detail.pcDetailTopMoreOtherSeller.6.4750Z0OpZ0Opr8&gps-id=pcDetailTopMoreOtherSeller&scm=1007.40000.327270.0&scm_id=1007.40000.327270.0&scm-url=1007.40000.327270.0&pvid=49ed7443-02c4-44da-8c90-0e1da987261e&_t=gps-id:pcDetailTopMoreOtherSeller,scm-url:1007.40000.327270.0,pvid:49ed7443-02c4-44da-8c90-0e1da987261e,tpp_buckets:668%232846%238108%231977&pdp_npi=4%40dis%21EUR%2118.45%2118.45%21%21%2119.55%2119.55%21%40210307bf17113131825435022e5162%2110000000763740227%21rec%21DE%21177306676%21&utparam-url=scene%3ApcDetailTopMoreOtherSeller%7Cquery_from%3A&search_p4p_id=202403241346225886633656498740913014_5)
  - [DS18B20 5x10m](https://www.aliexpress.com/item/1005005757890693.html?spm=a2g0o.productlist.main.7.56bc70862SMXUA&algo_pvid=e3bef03f-807f-41ce-8f3e-2c5b09732a02&algo_exp_id=e3bef03f-807f-41ce-8f3e-2c5b09732a02-3&pdp_npi=4%40dis%21EUR%2117.81%2114.25%21%21%2118.87%2115.10%21%402101e83017113136312465889efae0%2112000034246789615%21sea%21DE%21177306676%21&curPageLogUid=ZETpUSUx2reu&utparam-url=scene%3Asearch%7Cquery_from%3A)

# Software 
## Node-RED
Preferably use Docker for Node-RED, but will have to find a way to expose GPIO pins
```bash
docker run --restart=always --detach --name nodered -p 1880:1880 nodered/node-red
```

### Packages
- [Node-RED RPi GIPO](https://nodered.org/docs/faq/interacting-with-pi-gpio#node-red-node-pi-gpio)
- [Node-RED dashboard](https://flows.nodered.org/node/@flowfuse/node-red-dashboard)
  - This package could be improved with little extra work (Single component for all pins, single call to extract register data to optimize the flow)

## InfluxDB
InfluxDB is a real-time insights platform for any time series data with a single, purpose-built database.  
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
MQTT is used to open communication between the Raspberry Pi and Arduino
```bash
docker run --restart=always --detach --name emqx -p 1883:1883 -p 8083:8083 -p 8084:8084 -p 8883:8883 -p 18083:18083  emqx:5.5.1
```
