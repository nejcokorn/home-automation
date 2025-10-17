# Main Module PCB (r1.0)

**Supply:** 24 VDC (21.6–26.4 V) • **MCU:** STM32F103RCT6 • **Logic:** 3.3 V  
**Purpose:** Central controller with **isolated digital inputs**, headers for **programming**, **communication modules** (e.g., CAN). Supports expansion, **output modules** (currently **Relay module**; future: **PWM LED output** for LED strips).

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

---

## DIP switch configuration

Use the DIP switches to select the **operating mode** of the module:

- **Slave mode** — the module acts as a **slave**; a **Raspberry Pi** (master) handles communication and logic.
- **Stand-alone mode** — the module runs **without** a Raspberry Pi; e.g., **Input 1** directly triggers **Output 1** (1:1 mapping).
- **Blinds mode** — dedicated logic for blinds (UP/DOWN/STOP, interlock between directions, timing safeguards).
- **Push buttons → lights** — for **momentary push buttons**; supports **toggle**, **long-press**, **double-click** behaviors.
- **Switch mode (latching switches → lights)** — for **latching switches**; the switch state directly controls the output state.


---
