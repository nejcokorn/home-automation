# STM32GPIO I2C Communication Protocol

## I2C Addressing
- The protocol reserves **16 addresses**, ranging from **0x20 to 0x3F**.
- The address format is **01AA AAAX**, where:
  - `0100 000X` = **0x20** (starting address)
  - `0111 111X` = **0x3F** (ending address)
  - `X` = **1 for read, 0 for write**.

## Data Packet Structure
Each I2C transaction consists of **4 bytes**:

| Byte | Description |
|------|-------------|
| 1    | Address (7-bit) + R/W bit |
| 2    | Command/Register |
| 3    | Data Byte 1 (LSB) |
| 4    | Data Byte 2 (MSB) |

### Message Frame Format
```
01AA AAAX CTSP PPPP DDDD DDDD DDDD DDDD
```
Where:
- **X** → `1 = Read`, `0 = Write`
- **AAAAA** → Optional address bits
- **C (Configure)** → `1 = Configure STM32`
- **T (Type)** → `0 = Output`, `1 = Input`
- **S (Signal)** → `0 = Digital ports`, `1 = Analog ports`
- **P (Port Number)** → `0 = All ports, 1-32 = specific port`
- **D (Data)** → 16-bit data payload (sent as **LSB first, then MSB**)

## Communication Rules
1. Each transaction starts with the **I2C address** followed by the **command/register byte**.
2. The next two bytes contain **data**, depending on the command type.
3. **Analog ports** can **only be read one by one**.

## Example Transactions
### Writing Data to a Specific Port
1. Master sends **I2C address (0x20 - 0x3F)** with write bit (`X=0`).
2. Sends **command/register byte**.
3. Sends **two data bytes** (**LSB first, then MSB**).
4. Slave acknowledges and processes the data.

### Reading Data from an Analog Port
1. Master sends **I2C address** with read bit (`X=1`).
2. Sends **command/register byte**.
3. Slave responds with **two data bytes** (**LSB first, then MSB**).
