# STM32GPIO CAN Communication Protocol

## 1. Frame Format

Each CAN message uses a payload of **8 bytes (DLC = 8)**.

```
B1         B2         B3         B4         B5         B6         B7         B8
XXXX XXXX  CDPA Exxx  CMOO SDTT  PPPP PPPP  DDDD DDDD  DDDD DDDD  DDDD DDDD  DDDD DDDD
From       CommCtrl   DataCtrl   Port       Data MSB   Data       Data       Data LSB
```

### 1.1 Frame Definitions

The **receiver ID** is not included in the payload; it is encoded in the **CAN identifier field**, which ranges from **0x000 to 0x0FF** (8-bit logical receiver ID).  
**Broadcast address** to address all devices is 0x7FF.

* **B1 From**: 8-bit sender ID (`0x00–0xFF`).

* **B2 CommCtrl (Communication Control)** — bit-coded:

  * **C (Message Type)**: `0 = Data push event`, `1 = Command`.
  * **D (Discovery)**: `1 = Discover other devices on the network`.
    * Only reply to the broadcast address.
  * **P (Ping)**: `ACK = 0 & P = 1 => Ping device, ACK = 1 & P = 1 => Pong back`.
    * Only reply to the broadcast/deviceId address.
  * **A (Acknowledge)**: `1 = Acknowledge (response to a Command)`.
  * **E (Error)**: `1 = Error (response to a Command)`.
  * **xxx (Reserved)**: set to `0`.

* **B3 DataCtrl (Data Control)** — bit-coded:

  * **C (Config)**: `1 = Configure device`.
  * **M (EEPROM)**: `1 = Save configuration to EEPROM`.
    * Data bytes B5..B8 are set to 0.
  * **OO (Operation)**:
    * `00 = Read`.
    * `01 = Write`.
    * `10 = Toggle`.
    * `11 = Reserved`.
  * **S (Signal)**: `0 = Digital`, `1 = Analog`.
  * **D (Direction)**: `0 = Output ports`, `1 = Input ports`.
  * **TT (Type)**:
    * `00 = Bit`.
    * `01 = Byte (8-bit)`.
    * `10 = Integer (32-bit)`, `When D = 0 and B4 != 0, data represent delay off in miliseconds`.
    * `11 = Float`.

* **B4 Port**: `0–255 = port selection`.

* **B5 Data/ConfigCtrl**
  * **When C=0 (No configuration)**:
    * 32-bit payload, **B5..B8 Data, MSB first**.
  * **When C=1 (Config)**:
    * **B5 (Options)**: Values for each option are present in B6, B7, B8
      * `00000 = Input acts as a Button on rising edge`
      * `00001 = Input acts as a Button on falling edge`
      * `00010 = Input acts as Switch`
      * `00011 = Action toggle output pins`
      * `00100 = Action high output pins`
      * `00101 = Action low output pins`
      * `00110 = Debounce in microseconds`
      * `00111 = Longpress in milliseconds`
      * `01000 = Delay off in milliseconds`
        * `Longpress is the trigger for this action.`
      * `01001 = Bypass Instantly`
      * `01010 = Bypass determined by DIP switch`
      * `01011 = Bypass on disconnect in milliseconds`

* **B6..B8 Data**: 24/32-bit payload, **MSB first**

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
CAN ID = 0x000 + <deviceID>
From = <deviceID>
CommCtrl: C=0 D=1 P=0 A=1 E=0
DataCtrl: C=0 M=0 O=0 D=1 T=01
Port = 0
Data = <firmware>
```

---

## 6. Field Summary

| Byte | Name     | Description                          |
| ---- | -------- | ------------------------------------ |
| B1   | From     | Sender ID (`0x00–0xFF`)              |
| B2   | CommCtrl | Bit-coded: `C D P A E xxx`           |
| B3   | DataCtrl | Bit-coded: `C M OO S D TT`           |
| B4   | Port     | `0–255` = port ID                    |
| B5   | Data MSB | Data payload, most significant byte  |
| B6   | Data     | Data payload                         |
| B7   | Data     | Data payload                         |
| B8   | Data LSB | Data payload, least significant byte |

---

## 7. Examples
TODO
