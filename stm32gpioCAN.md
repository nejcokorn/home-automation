# CAN Communication Protocol

## 1. CAN Identifier
### 1.1 Identifier Format

The STM32 GPIO protocol uses **CAN 2.0B Extended Identifiers (29-bit)**.

**Valid identifier range:**

* Minimum: `0x00000000`
* Maximum: `0x1FFFFFFF`

---

### 1.2. CAN ID Structure

The 29-bit CAN identifier is divided into logical fields that enable command routing, fragmentation, and device addressing.

### 1.2.1 Bit Layout

| Field       | Bit Range | Mask       | Description                                             |
| ----------- | --------- | ---------- | ------------------------------------------------------- |
| commandId   | [28:16]   | 0x1FFF0000 | Identifies the command type and sequence.               |
| initiatorId | [15:8]    | 0x0000FF00 | ID of the device or agent initiating the communication. |
| responderId | [7:0]     | 0x000000FF | ID of the device expected to respond.                   |

> **Note:** The `commandId` implicitly acts as a **Package ID** when a command is fragmented across multiple CAN frames. All frames belonging to the same transaction must share the same `commandId`.

---

### 1.3. Device ID Usage

The `initiatorId` and `responderId` fields identify **logical agents** as well as **physical devices** on the CAN bus.

#### 1.4.1 Reserved Agent Device IDs

The following `DeviceId` values are reserved for agent-level commands:

| Command Name    | DeviceId |
| --------------- | -------- |
| getPort         | 0xF0     |
| setPort         | 0xF1     |
| discover        | 0xF2     |
| ping            | 0xF3     |
| getConfig       | 0xF4     |
| setConfig       | 0xF5     |
| writeEEPROM     | 0xF6     |
| listDelays      | 0xF7     |
| clearDelay      | 0xF8     |
| broadcastAction | 0xFF     |

* `0xFF` is reserved for **broadcast commands**
* Device IDs below `0xF0` are available for physical devices

## 2. CAN Data - Frame Format

Each CAN message uses a payload of **8 bytes (DLC = 8)**.

```
B1         B2         B3         B4         B5         B6         B7         B8
DPAE WNxx  CCSD TTxx  OOOO OOOO  PPPP PPPP  DDDD DDDD  DDDD DDDD  DDDD DDDD  DDDD DDDD
CommCtrl   DataCtrl   Operation  Port       Data MSB   Data       Data       Data LSB
```

### 2.1 Frame Definitions

The **receiver ID** is not included in the payload; it is encoded in the **CAN identifier field**, which ranges from **0x000 to 0x0FF** (8-bit logical receiver ID).  
**Broadcast address** to address all devices is 0x7FF.

* **B1 CommCtrl (Communication Control)** — bit-coded:

  * **D (Discover)**: `1 = Discover other devices on the network`.
    * Only reply to the broadcast address.
  * **P (Ping)**: `ACK = 0 & P = 1 => Ping device, ACK = 1 & P = 1 => Pong back`.
    * Only reply to the broadcast/deviceId address.
  * **A (Acknowledge)**: `1 = Acknowledge (response to a Command)`.
  * **E (Error)**: `1 = Error (response to a Command)`.
  * **W (Wait)**: `1 = Wait for next frame`.
  * **N (Notify)**: `1 = Notification frame. The package is sent for informational purposes only - does not require any response or action from the receiver.`
  * **X (Reserved)**: set to `0`.
  * **X (Reserved)**: set to `0`.

* **B3 DataCtrl (Data Control)** — bit-coded:

  * **C (Command)**: `1 = Command`, `0 = Data push`.
  * **C (Config)**: `1 = Config command`.
  * **S (Signal)**: `0 = Digital`, `1 = Analog`.
  * **D (Direction)**: `0 = Output ports`, `1 = Input ports`.
  * **TT (Data Type)**:
    * `00 = Bit`.
    * `01 = Byte (8-bit)`.
    * `10 = Integer (32-bit)`, `When D = 0 and B4 != 0, data represent delay low in miliseconds`.
    * `11 = Float`.
  * **X (Reserved)**: set to `0`.
  * **X (Reserved)**: set to `0`.

* **B3 Operations**:
  * **Command operations**
    * `0x00 = Get/Push`.
      * Get the current state of the input/output ports
    * `0x01 = Set output port`.
      * Set the desired state to the output ports.
        * 0 = low
        * 1 = high
        * 2 = toggle
        * 3 = pwm
    * `0x02 = Delay in milliseconds`.
    * `0x03 = List all delays`.
      * Returned information is retrieved in multiple packages. Until the last package is sent, include a wait bit.
        * 1. Delay id
        * 2. Device id
        * 3. Executable
        * 4. Package with the desired future state, 0 = LOW, 1 = HIGH, 2 = TOGGLE, 3 = PWM
        * 5. Delay in milliseconds
    * `0x04 = Clear delay by id`.
      * Data must contain the id of the delay to be cleared out.
    * `0x05 = Clear delay by port`.
      * This will clear out delays on all devices related to that device and port.

  * **Config operations**
    * `0x00 = Save configuration to EEPROM`
    * `0x01 = Get Debounce in microseconds`
    * `0x02 = Get Double-click in milliseconds`
    * `0x03 = Get Get/Reset all actions`
    * `0x04 = Get Action P1 base - deviceId (B5), trigger (B6), mode (B7), type (B8)`
    * `0x05 = Get Action P2 ports (map)`
    * `0x06 = Get Action P3 skip action if delay is present in any of the output ports (map)`
    * `0x07 = Get Action P4 clear all delays on all specified output ports (map)`
    * `0x08 = Get Action P5 delay in milliseconds`
    * `0x09 = Get Action P6 longpress in milliseconds`
    * `0x0A = Get Bypass Instantly`
    * `0x0B = Get Bypass determined by DIP switch`
    * `0x0C = Get Bypass on disconnect in milliseconds`
    * `0x81 = Set Debounce in microseconds`
    * `0x82 = Set Double-click in milliseconds`
    * `0x83 = Set Get/Reset all actions`
    * `0x84 = Set Action P1 base - deviceId (B5), trigger (B6), mode (B7), type (B8)`
    * `0x85 = Set Action P2 ports (map)`
    * `0x86 = Set Action P3 skip action if delay is present in any of the output ports (map)`
    * `0x87 = Set Action P4 clear all delays on all specified output ports (map)`
    * `0x88 = Set Action P5 delay in milliseconds`
    * `0x89 = Set Action P6 longpress in milliseconds`
    * `0x8A = Set Bypass Instantly`
    * `0x8B = Set Bypass determined by DIP switch`
    * `0x8C = Set Bypass on disconnect in milliseconds`

* **B4 Port**: `0–255 = port selection`.

* **B5..B8 Data**: 32-bit payload, **MSB first**

---

## 3. DIP Switches
The STM32GPIO device has two sets of DIP Switches on board:
* **A1..A5** - This DIP switch determines the **device ID**. `0 = 500kbps, 1 = 1Mbps`.
* **C1..C2**
  * **C1** is used to determine **CAN2.0 spead**.
  * **C2** is used to set the device "**bypass on the DIP switch**". `1 = Bypass`.

---

## 4. Communication Rules

1. **Command** frames (`C=1`) require an **Acknowledge** response (`A=1`), or an **Error** response (`E=1`) with mirrored `CommCtrl/DataCtrl` fields and resulting `Data`.
2. **Push** frames (`C=0`) are asynchronous and do not require acknowledgement.
3. **Broadcast** is achieved by sending the frame with a broadcast CAN ID (`0x2FF`). Discovery requests are broadcast; discovery responses are unicast.
4. **Ping/Pong**:

   * `C=1, P=1, A=0` → Ping request.
   * `C=1, P=1, A=1` → Pong response (same CommCtrl mirrored).

---

## 5. Error Handling

On processing failure, the Acknowledge frame (`A=1, E=1`) carries an error code in **Data**:

| Code | Meaning       |
| ---- | ------------- |
| TBD  | To be decided |

---

## 6. Discovery

### 6.1 Request (broadcast)

```
CAN ID = 0x2FF
From = <requester>
CommCtrl: C=1 D=1 P=0 A=0 E=0
DataCtrl: C=0 M=0 O=0 D=0 T=00
Port = 0
Data = 0x00000000
```

### 6.2 Response (per device, unicast)

```
CAN ID = 0x000 + <deviceID>
From = <deviceID>
CommCtrl: C=0 D=1 P=0 A=1 E=0
DataCtrl: C=0 M=0 O=0 D=1 T=01
Port = 0
Data = <firmware>
```

---

## 7. Field Summary

| Byte | Name     | Description                          |
| ---- | -------- | ------------------------------------ |
| B1   | From     | Sender ID (`0x00–0xFF`)              |
| B2   | CommCtrl | Bit-coded: `C D P A W E xx`          |
| B3   | DataCtrl | Bit-coded: `C M OO S D TT`           |
| B4   | Port     | `0–255` = port ID                    |
| B5   | Data MSB | Data payload, most significant byte  |
| B6   | Data     | Data payload                         |
| B7   | Data     | Data payload                         |
| B8   | Data LSB | Data payload, least significant byte |

---

## 8. Examples
TODO
