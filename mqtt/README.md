# Home Assistant
## How to setup Home Assistant using Docker engine
```bash
docker run -d homeassistant/home-assistant
```


# MQTT5
## How to setup the MQTT5 Mosquitto using Docker engine
Instruction in details https://github.com/sukesh-ak/setup-mosquitto-with-docker

## How to setup the MQTT5 emqx using Docker engine
docker run --restart=always --detach --name emqx -p 1883:1883 -p 8083:8083 -p 8084:8084 -p 8883:8883 -p 18083:18083  emqx:5.5.1


# Node red
Want it or not, it is still the best
```bash
docker run -it -p 1880:1880 nodered/node-red
docker run -it -p 1880:1880 -v myNodeREDdata:/data --name mynodered nodered/node-red
```
