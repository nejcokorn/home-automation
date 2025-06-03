# STM32GPIO I2C + MQTT Communication Protocol

## Purpose

This document describes the communication protocol between a controller device (e.g., a Linux-based system such as Raspberry Pi, Orange Pi, BeagleBone, etc.), STM32 devices via I2C, and user systems/services via MQTT. The purpose is to enable reading, writing, and configuration of GPIO ports on STM32 devices in a standardized, extensible, and Home Assistant / Node-RED compatible way.

---

## MQTT Topic Structure

```
stm32gpio/<device_id>/<type>/<signal>/<port>/<action>
```

### Segments:

* `<device_id>`: Device ID (e.g., `20`) or `+` for wildcard
* `<type>`: Port direction: `input`, `output`
* `<signal>`: Signal type: `digital`, `analog`
* `<port>`: Port number `0`–`31` or `+`
* `<action>`: Operation: `set`, `get`, `event`, `error`

---

## Action Semantics

| Action  | Meaning                                                     | Initiator            | Response               |
| ------- | ----------------------------------------------------------- | -------------------- | ---------------------- |
| `set`   | Set the value or configuration of a port                    | User / Node-RED / HA | `event` (confirmation) |
| `get`   | Request the value or configuration of a port                | User / Node-RED      | `event` (response)     |
| `event` | Device publishes a value (in response to get/set/interrupt) | Controller / STM32   | /                      |
| `error` | Device reports an error                                     | Controller           | /                      |

---

## Topic and Payload Examples

### Set digital output:

**Topic:**

```
stm32gpio/20/output/digital/3/set
```

**Payload:**

```json
{ "value": 1 }
```

### Read analog input:

**Topic:**

```
stm32gpio/20/input/analog/2/get
```

**Payload:**

```json
{}
```

**Response (event):**

```
stm32gpio/20/input/analog/2/event
```

```json
{ "value": 843, "timestamp": 1717415090, "source": "get" }
```

### Configure digital port:

**Topic:**

```
stm32gpio/20/output/digital/5/set
```

**Payload:**

```json
{ "mode": "hybrid", "output": 5 }
```

### Error:

**Topic:**

```
stm32gpio/20/output/digital/12/error
```

**Payload:**

```json
{ "code": "PORT_INVALID", "message": "Port out of range" }
```

---

## Wildcards and Broadcast

* MQTT `+` wildcard is used for **subscribing** to all ports or devices.
* To **send commands to all devices**, a pseudo-ID `broadcast` can be used:

```
stm32gpio/broadcast/output/digital/3/set
```

The controller will recognize `broadcast` and apply the command to all known devices.

---

## Home Assistant Integration

* `set` = `command_topic`
* `event` = `state_topic`
* `get` is **not used** by Home Assistant (no native support for MQTT get requests)

### Example HA Configuration:

```yaml
mqtt:
  switch:
    - name: "Relay 1"
      command_topic: "stm32gpio/20/output/digital/1/set"
      state_topic: "stm32gpio/20/output/digital/1/event"
      payload_on: '{"value":1}'
      payload_off: '{"value":0}'
      value_template: "{{ value_json.value }}"
      state_on: 1
      state_off: 0
      force_update: true
```

---

## Node-RED Integration

Node-RED can:

* publish `get`, `set`, and `configure` commands
* listen for `event` and `error` responses
* use inject, function, MQTT in/out, switch, debug nodes
