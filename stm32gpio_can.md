# STM32GPIO CAN Communication Protocol

## 1. Frame Format

Each CAN message uses a payload of **8 bytes (DLC = 8)**.

```
B1         B2         B3         B4         B5         B6         B7         B8
XXXX XXXX  REAO Cxxx  DTTx xxx   PPPP PPPP  DDDD DDDD  DDDD DDDD  DDDD DDDD  DDDD DDDD
From       CommCtrl   DataCtrl   Port       Data MSB   Data       Data       Data LSB
```

### 1.1 Frame Definitions

The **receiver ID** is not included in the payload; it is encoded in the **CAN identifier field**, which ranges from **0x200 to 0x2FF** (8-bit logical receiver ID).

* **B1 From**: 8-bit sender ID (`0x00–0xFF`).
* **B2 CommCtrl (Communication Control)** — bit-coded:
  * **R (Frame Role)**: `0 = Data push event`, `1 = Command`.
  * **D (Discovery)**: `1 = Discover other devices on the network`.
  * **A (Acknowledge)**: `1 = Acknowledge (response to a Command)`.
  * **E (Error)**: `1 = Error (response to a Command)`.
  * **O (Operation)**: `0 = Read`, `1 = Write`.
  * **C (Config)**: `1 = Configure device`.
  * **xx (Reserved)**: set to `0`.

* **B3 DataCtrl (Data Control)** — bit-coded:
  * **D (Data source/Direction)**: `0 = Output ports`, `1 = Input ports`.
  * **T (Type)**: `00 = Bit`, `01 = Byte (8-bit)`, `10 = Integer (32-bit)`, `11 = Float`.
  * **xxxxx (Reserved)**: set to `0`.

* **B4 Port**: `0 = All ports` (only valid with singular type), `1–255 = specific port`.
* **B5..B8 Data**: 32-bit payload, **MSB first** (B5), then LSB (B8).

---

## 2. Communication Rules

1. **Command** frames (`R=1`) require an **Acknowledge** response (`A=1`), or an **Error** response (`E=1`) with mirrored `CommCtrl/DataCtrl` fields and resulting `Data`.
2. **Push** frames (`R=0`) are asynchronous and do not require acknowledgement.
3. **Broadcast** is achieved by sending the frame with a broadcast CAN ID (`0x2FF`). Discovery requests are broadcast; discovery responses are unicast.

---

## 3. Data Class and Port Semantics

### 3.1 Singular (B3-D = 0)

* **Read, Port = 0**: returns a **bitmap** of singular states in `Data` (bit 0 → port 1, …).
* **Read, Port = k (1–255)**: returns state of port *k* in `Data bit0` (`0/1`).
* **Write, Port = 0**: applies `Data` bitmap to all singular outputs.
* **Write, Port = k**: applies `Data bit0` to port *k*.

### 3.2 Byte (B3-D = 1)

* **Port = 0**: **not permitted** (operation error).
* **Read/Write, Port = k (1–255)**: transfers an 8-bit value in `Data`.

---

## 4. Error Handling

On processing failure, the Acknowledge frame (`A=1, E=1`) carries an error code in **Data**:

| Code            | Meaning                    |
| --------------- | -------------------------- |

TBD - To be decided

---

## 5. Discovery

### 5.1 Request (broadcast)

```
CAN ID = 0x2FF
From = <requester>
CommCtrl: R=1 D=1 A=0 E=0 O=0 C=0
DataCtrl: D=0 T=00
Port = 0
Data = 0x00000000
```

### 5.2 Response (per device, unicast)

```
CAN ID = 0x200 + <deviceID>
From = <deviceID>
CommCtrl: R=0 D=1 A=1 E=0 O=0 C=0
DataCtrl: D=1 T=01
Port = 0
Data = <version/capability information>
```

---

## 6. Field Summary

| Byte | Name     | Description                                                        |
| ---- | -------- | ------------------------------------------------------------------ |
| B1   | From     | Sender ID (`0x00–0xFF`)                                            |
| B2   | CommCtrl | Bit-coded: `R D A E O C xx`                                        |
| B3   | DataCtrl | Bit-coded: `D TT xxxxx`                                            |
| B4   | Port     | `0` = all ports (only valid with singular type), `1–255` = port ID |
| B5   | Data MSB | Data payload, most significant byte                                |
| B6   | Data     | Data payload                                                       |
| B7   | Data     | Data payload                                                       |
| B8   | Data LSB | Data payload, least significant byte                               |

---

## 7. Examples

### 7.1 Write Singular (bit) — Port 5 = ON

```
CAN ID = 0x212   (receiver device ID = 0x12)
From=0x01
CommCtrl: R=1 D=0 A=0 E=0 O=1 C=0
DataCtrl: D=0 T=00
Port=5
Data=0x00000001
```

**Acknowledge**

```
CAN ID = 0x201   (receiver = requester 0x01)
From=0x12
CommCtrl: R=1 D=0 A=1 E=0 O=1 C=0
DataCtrl: D=0 T=00
Port=5
Data=0x00000001
```

---

### 7.2 Write Singular (bit) — Global Bitmap

```
CAN ID   = 0x212
From=0x01
CommCtrl: R=1 D=0 A=0 E=0 O=1 C=0
DataCtrl: D=0 T=00
Port=0
Data=0x000000F3
```

---

### 7.3 Read Byte (8-bit) — Port 3

```
CAN ID = 0x212   (receiver device ID = 0x12)
From=0x01
CommCtrl: R=1 D=0 A=0 E=0 O=0 C=0
DataCtrl: D=1 T=01
Port=3
Data=0x00000000
```

**Acknowledge**

```
CAN ID = 0x201   (receiver = requester 0x01)
From=0x12
CommCtrl: R=1 D=0 A=1 E=0 O=0 C=0
DataCtrl: D=1 T=01
Port=3
Data=0x000000F2
```

---

### 7.4 Invalid Operation — Read Byte with Port=0

```
CAN ID = 0x212   (receiver device ID = 0x12)
From=0x01
CommCtrl: R=1 D=0 A=0 E=0 O=0 C=0
DataCtrl: D=1 T=01
Port=0
Data=0x00000000
```

**Acknowledge (error)**

```
CAN ID = 0x201   (receiver = requester 0x01)
From=0x12
CommCtrl: R=1 D=0 A=1 E=1 O=0 C=0
DataCtrl: D=1 T=01
Port=0
Data=0x00000002
```

---
