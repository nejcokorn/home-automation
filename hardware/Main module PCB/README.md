# Main Module PCB (r1.0)

**Supply:** 24 VDC (21.6–26.4 V) • **MCU:** STM32F103RCT6 • **Logic:** 3.3 V  
**Purpose:** Central controller with **isolated digital inputs**, backplane **module connectors**, and headers for **programming** and **communication modules** (e.g., CAN). Supports expansion **output modules** (currently **Relay module**; future: **PWM LED output** for LED strips).

---

## Key features
- **16× optically isolated inputs** (with software **debounce**)
- **Backplane/connectors** for:
  - other functional modules (expansion)
  - programming (SWD)
  - communication module (**CAN module**, more in future)
  - output expansion (**Relay module** now; more types coming)
- **Power tree**
  - 24 VDC → **3.3 V buck**: *LMR51430XFDDCR*
  - **Supervisor**: *TLV809EA30DBZR* (3.0 V reset monitor)
- **MCU**
  - *STM32F103RCT6* (HSE **8 MHz crystal**)
  - **Reset button**, **DIP switches** for operating modes / addresses

---

## Electrical specifications
| Item | Value / Notes |
|---|---|
| Input supply | **21.6–26.4 VDC** (nominal 24 VDC, SELV) |
| Logic rail | **3.3 V** via **LMR51430** buck |
| Supervisor | **TLV809EA30** (3.0 V threshold) |
| MCU | **STM32F103RCT6**, HSE **8 MHz** |
| Digital inputs | **16×** opto-isolated (TLP290-4) |
| Input debounce | **Software debounce** in firmware |
| Protection | TVS on 24 V, proper decoupling on 3.3 V (see schematic) |

> Note: Place adequate bulk capacitance on 24 V line close to the buck; follow layout guidelines for **LMR51430** (short switch node, solid ground).

---

## Connectors (overview)
*(Exact part numbers and pinouts are documented in the schematic PDFs – list here is for navigation.)*

- **Jx – Module connectors (backplane)**: power + I/O bus to daughter boards  
- **J_SW** – **SWD** programming header (SWDIO, SWCLK, 3V3, GND, NRST)  
- **J_COMM** – **Communication module** header (for **CAN module**; power, CAN, control)  
- **J_OUT** – **Output expansion** header (for **Relay module**; power + control bus)  
- **J_IN*** – Terminal blocks for **16× isolated inputs** (naming JIN1…JIN16)  
- **BTN_RST** – **Reset button**  
- **SW_DIP** – **DIP switches** for **mode/address** configuration

> Add detailed pin tables per connector in this README when finalized (see template below).

---

## DIP switch configuration
Typical use cases (examples; align with firmware):
- **Address / Node ID** selection  
- **Operating mode** (e.g., I/O mapping profile, debounce time preset)  
Document final mapping in firmware and mirror it here.

---

## Firmware notes
- Target: **STM32F103RCT6** (HAL/CMSIS).  
- **Clocking:** HSE **8 MHz** → PLL per project.  
- **Input handling:** edge detection with **software debounce** (tunable).  
- **Supervisor:** handle **TLV809** reset line; ensure clean startup sequence.  
- **Boot/Debug:** **SWD**; optional UART log for bring-up.

---

## Bring-up / test procedure
1. **Visual inspection** (orientation, polarity, solder bridges).  
2. Power from **current-limited** 24 V supply (limit ≤ 0.3 A first). Verify **3.3 V**.  
3. Check **reset supervisor** action (hold below 3.0 V → reset asserted).  
4. Program MCU over **SWD**; confirm heartbeat LED (if available).  
5. Exercise **inputs** (simulate via 24 V sources) and observe debounced states.  
6. Connect **Relay module** and **CAN module** (if present) and run I/O smoke test.

---

## Files in this folder
