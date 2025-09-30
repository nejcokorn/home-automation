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
  * **M (EPROM)**: `1 = Save configuration to EPROM`.
  * **O (Operation)**: `0 = Read`, `1 = Write`.
  * **D (Data source/Direction)**: `0 = Output ports`, `1 = Input ports`.
  * **T (Type)**: `00 = Bit`, `01 = Byte (8-bit)`, `10 = Integer (32-bit)`, `11 = Float`.
  * **xx (Reserved)**: set to `0`.

* **B4 Port**: `0 = All ports`, `1–255 = specific port`.

* **B5..B8 Data**: 32-bit payload, **MSB first** (B5), then LSB (B8).

---

## 2. Communication Rules

1. **Command** frames (`C=1`) require an **Acknowledge** response (`A=1`), or an **Error** response (`E=1`) with mirrored `CommCtrl/DataCtrl` fields and resulting `Data`.
2. **Push** frames (`C=0`) are asynchronous and do not require acknowledgement.
3. **Broadcast** is achieved by sending the frame with a broadcast CAN ID (`0x2FF`). Discovery requests are broadcast; discovery responses are unicast.
4. **Ping/Pong**:

   * `C=1, P=1, A=0` → Ping request.
   * `C=1, P=1, A=1` → Pong response (same CommCtrl mirrored).

---

## 3. Data Class and Port Semantics

### 3.1 Manage multiple ports (B3-C/M/O/D/T)

* **Read, Port = 0**: returns a **bitmap** of all digital input/output port states in `Data` (bit 0 → port 1, …).
* **Read, Port = k (1–255)**: returns state of port *k* in `Data bit0` (`0/1`).
* **Write, Port = 0**: applies `Data` bitmap to all outputs.
* **Write, Port = k**: applies `Data bit0` to port *k*.

### 3.2 Byte (T=01)

* **Port = 0**: **not permitted** (operation error).
* **Read/Write, Port = k (1–255)**: transfers an 8-bit value in `Data`.

---

## 4. Error Handling

On processing failure, the Acknowledge frame (`A=1, E=1`) carries an error code in **Data**:

| Code | Meaning       |
| ---- | ------------- |
| TBD  | To be decided |

---

## 5. Discovery

### 5.1 Request (broadcast)

```
CAN ID = 0x2FF
From = <requester>
CommCtrl: C=1 D=1 P=0 A=0 E=0
DataCtrl: C=0 M=0 O=0 D=0 T=00
Port = 0
Data = 0x00000000
```

### 5.2 Response (per device, unicast)

```
CAN ID = 0x200 + <deviceID>
From = <deviceID>
CommCtrl: C=0 D=1 P=0 A=1 E=0
DataCtrl: C=0 M=0 O=0 D=1 T=01
Port = 0
Data = <version/capability information>
```

---

## 6. Field Summary

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

## 7. Examples

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

### 7.2 Write to all digital output ports (bit) — Global Bitmap

```
CAN ID   = 0x212
From=0x01
CommCtrl: C=1 D=0 P=0 A=0 E=0
DataCtrl: C=0 M=0 O=1 D=0 T=00
Port=0
Data=0x000000F3
```

---

### 7.3 Read Byte (8-bit) — Port 3

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

### 7.4 Invalid Operation — Read Byte with Port=0

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

### 7.5 Ping/Pong Example

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
