# STM32GPIO CAN Communication Protocol

## 1. Frame Format

Each CAN message uses a payload of **8 bytes (DLC = 8)**.

```
B1         B2         B3         B4         B5         B6         B7         B8
XXXX XXXX  CDPA Exxx  CMOD TTxx  PPPP PPPP  DDDD DDDD  DDDD DDDD  DDDD DDDD  DDDD DDDD
From       CommCtrl   DataCtrl   Port       Data MSB   Data       Data       Data LSB
```

### 1.1 Frame Definitions

The **receiver ID** is not included in the payload; it is encoded in the **CAN identifier field**, which ranges from **0x200 to 0x2FF** (8-bit logical receiver ID).

* **B1 From**: 8-bit sender ID (`0x00–0xFF`).

* **B2 CommCtrl (Communication Control)** — bit-coded:

  * **C (Message Type)**: `0 = Data push event`, `1 = Command`.
  * **D (Discovery)**: `1 = Discover other devices on the network`.
  * **P (Ping)**: `ACK = 0 & P = 1 => Ping device, ACK = 1 & P = 1 => Pong back`.
  * **A (Acknowledge)**: `1 = Acknowledge (response to a Command)`.
  * **E (Error)**: `1 = Error (response to a Command)`.
  * **xxx (Reserved)**: set to `0`.

* **B3 DataCtrl (Data Control)** — bit-coded:

  * **C (Config)**: `1 = Configure device`.
  * **M (EEPROM)**: `1 = Save configuration to EEPROM`.
    * Data bytes B5..B8 are set to 0.
  * **O (Operation)**: `0 = Read`, `1 = Write`.
  * **D (Direction)**: `0 = Output ports`, `1 = Input ports`.
    * `D = 0, B4 != 0` => data bytes B5..B8 represent delay off in miliseconds.
  * **TT (Type)**: `00 = Bit`, `01 = Byte (8-bit)`, `10 = Integer (32-bit)`, `11 = Float`.
  * **xx (Reserved)**: set to `0`.

* **B4 Port**: `0 = All ports`, `1–255 = specific port`.

* **B5 Data/ConfigCtrl**
  * **When C=0 (No configuration)**:
    * 32-bit payload, **B5..B8 Data, MSB first**.
  * **When C=1 (Config)**:
    * **T (Input Type)**: `1 = Input acts as Button, 0 = Input acts as Switch`.
    * **I (Bypass Instantly)**: `1 = Bypass instantly without checking for conditions`.
    * **D (Bypass On DIP switch)**: `1 = Bypass is determined by the DIP switch`.
    * **xx (Reserved)**: set to `0`.
    * **OOO (Options)**: Values for each option are present in B6, B7, B8
      * `000 = No changes to the options`.
      * `001 = Target output ports`.
      * `010 = Debounce in microseconds`.
      * `011 = Delay on in milliseconds - Longpress`.
      * `100 = Delay off in milliseconds`.
      * `101 = Bypass on disconnect in milliseconds`.
      * `111 = Reset all options (value 0)`.

* **B6..B8 Data**: 24/32-bit payload, **MSB first**.

---

## 2. DIP Switches
The STM32GPIO device has two sets of DIP Switches on board:
* **A1..A5** - This DIP switch determines the **device ID**. `0 = 500kbps, 1 = 1Mbps`.
* **C1..C2**
  * **C1** is used to determine **CAN2.0 spead**.
  * **C2** is used to set the device "**bypass on the DIP switch**". `1 = Bypass`.

---

## 3. Communication Rules

1. **Command** frames (`C=1`) require an **Acknowledge** response (`A=1`), or an **Error** response (`E=1`) with mirrored `CommCtrl/DataCtrl` fields and resulting `Data`.
2. **Push** frames (`C=0`) are asynchronous and do not require acknowledgement.
3. **Broadcast** is achieved by sending the frame with a broadcast CAN ID (`0x2FF`). Discovery requests are broadcast; discovery responses are unicast.
4. **Ping/Pong**:

   * `C=1, P=1, A=0` → Ping request.
   * `C=1, P=1, A=1` → Pong response (same CommCtrl mirrored).

---

## 4. Data Class and Port Semantics

### 4.1 Manage multiple ports (B3-C/M/O/D/T)

* **Read, Port = 0**: returns a **bitmap** of all digital input/output port states in `Data` (bit 0 → port 1, …).
* **Read, Port = k (1–255)**: returns state of port *k* in `Data bit0` (`0/1`).
* **Write, Port = 0**: applies `Data` bitmap to all outputs.
* **Write, Port = k**: applies `Data bit0` to port *k*.

### 4.2 Byte (T=01)

* **Port = 0**: **not permitted** (operation error).
* **Read/Write, Port = k (1–255)**: transfers an 8-bit value in `Data`.

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
CAN ID = 0x200 + <deviceID>
From = <deviceID>
CommCtrl: C=0 D=1 P=0 A=1 E=0
DataCtrl: C=0 M=0 O=0 D=1 T=01
Port = 0
Data = <version/capability information>
```

---

## 7. Field Summary

| Byte | Name     | Description                          |
| ---- | -------- | ------------------------------------ |
| B1   | From     | Sender ID (`0x00–0xFF`)              |
| B2   | CommCtrl | Bit-coded: `C D P A E xxx`           |
| B3   | DataCtrl | Bit-coded: `C M O D TT xx`           |
| B4   | Port     | `0` = all ports, `1–255` = port ID   |
| B5   | Data MSB | Data payload, most significant byte  |
| B6   | Data     | Data payload                         |
| B7   | Data     | Data payload                         |
| B8   | Data LSB | Data payload, least significant byte |

---

## 8. Examples

*(Prilagoditve samo za nove oznake C/M/O/D/T)*

### 7.1 Write to a specific port (bit) — Port 5 = ON

```
CAN ID = 0x212   (receiver device ID = 0x12)
From=0x01
CommCtrl: C=1 D=0 P=0 A=0 E=0
DataCtrl: C=0 M=0 O=1 D=0 T=00
Port=5
Data=0x00000001
```

**Acknowledge**

```
CAN ID = 0x201   (receiver = requester 0x01)
From=0x12
CommCtrl: C=1 D=0 P=0 A=1 E=0
DataCtrl: C=0 M=0 O=1 D=0 T=00
Port=5
Data=0x00000001
```

---

### 8.2 Write to all digital output ports (bit) — Global Bitmap

```
CAN ID   = 0x212
From=0x01
CommCtrl: C=1 D=0 P=0 A=0 E=0
DataCtrl: C=0 M=0 O=1 D=0 T=00
Port=0
Data=0x000000F3
```

---

### 8.3 Read Byte (8-bit) — Port 3

```
CAN ID = 0x212   (receiver device ID = 0x12)
From=0x01
CommCtrl: C=1 D=0 P=0 A=0 E=0
DataCtrl: C=0 M=0 O=0 D=1 T=01
Port=3
Data=0x00000000
```

**Acknowledge**

```
CAN ID = 0x201   (receiver = requester 0x01)
From=0x12
CommCtrl: C=1 D=0 P=0 A=1 E=0
DataCtrl: C=0 M=0 O=0 D=1 T=01
Port=3
Data=0x000000F2
```

---

### 8.4 Invalid Operation — Read Byte with Port=0

```
CAN ID = 0x212   (receiver device ID = 0x12)
From=0x01
CommCtrl: C=1 D=0 P=0 A=0 E=0
DataCtrl: C=0 M=0 O=0 D=1 T=01
Port=0
Data=0x00000000
```

**Acknowledge (error)**

```
CAN ID = 0x201   (receiver = requester 0x01)
From=0x12
CommCtrl: C=1 D=0 P=0 A=1 E=1
DataCtrl: C=0 M=0 O=0 D=1 T=01
Port=0
Data=0x00000002
```

---

### 8.5 Ping/Pong Example

**Ping request**

```
CAN ID = 0x212   (receiver device ID = 0x12)
From=0x01
CommCtrl: C=1 D=0 P=1 A=0 E=0
DataCtrl: C=0 M=0 O=0 D=0 T=00
Port=0
Data=0x00000000
```

**Pong response**

```
CAN ID = 0x201   (receiver = requester 0x01)
From=0x12
CommCtrl: C=1 D=0 P=1 A=1 E=0
DataCtrl: C=0 M=0 O=0 D=0 T=00
Port=0
Data=0x00000000
```

---
