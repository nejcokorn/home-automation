# MQTT5
## How to setup MQTT5 Mosquitto using Docker engine
Instruction in details https://github.com/sukesh-ak/setup-mosquitto-with-docker

## How to setup MQTT5 emqx using Docker engine
docker run --restart=always --detach --name emqx -p 1883:1883 -p 8083:8083 -p 8084:8084 -p 8883:8883 -p 18083:18083  emqx:5.5.1
