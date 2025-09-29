## Overview

https://www.waveshare.com/wiki/RS485_CAN_HAT#CAN_Usage
The RS485 CAN HAT is an expansion board for Raspberry Pi that adds:

* **CAN bus** via MCP2515 controller (connected over SPI) + SN65HVD230 transceiver
* **RS-485 (half duplex)** interface via SP3485 transceiver, controlled via the Pi’s UART (or optionally via manual control)

---

## Driver / Software Setup (on the Pi)

Below is a recommended procedure to enable and use both the CAN and RS-485 sides.

### Prerequisites

1. Make sure your Raspberry Pi OS (or other OS) is up to date.
2. Install needed packages:

```bash
sudo apt-get update
sudo apt-get install can-utils
```

### Enabling the CAN interface (MCP2515)

1. Edit the `config.txt` file (on Raspberry Pi OS) — on older releases it’s `/boot/config.txt`; on newer ones (or Ubuntu) it might be under 

   Append:

   ```
   dtparam=spi=on
   dtoverlay=mcp2515-can0,oscillator=12000000,interrupt=25,spimaxfrequency=2000000
   ```

   * Use `oscillator=12000000` if your HAT has a 12 MHz oscillator (most newer ones do).
   * If your HAT is an older version with an 8 MHz oscillator, use:

     ```
     dtparam=spi=on
     dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25,spimaxfrequency=1000000
     ```

2. Save and reboot:

```bash
sudo reboot
```

3. After reboot, check kernel messages to verify that the SPI / CAN driver is loaded:

```bash
dmesg | grep -i "\(can\|spi\)"
```

You should see messages indicating `mcp2515` and CAN device (e.g. `can0`) initialization.

4. Bring up the CAN interface with the appropriate bit rate. Example (1 Mbps):

```bash
sudo ip link set can0 up type can bitrate 1000000
sudo ifconfig can0 txqueuelen 65536
sudo ifconfig can0 up
```

Then you can use `ifconfig` to see `can0`.

5. Use `can-utils` to test:

* To receive:

  ```bash
  candump can0
  ```

* To send:

  ```bash
  cansend can0 000#11.22.33.44
  ```

If everything is wired and configured correctly, you should see the frames being sent/received.

### Enabling / Using RS-485 Interface

1. Enable the UART serial interface. Use:

```bash
sudo raspi-config
```

Then navigate to *Interfacing Options → Serial*.

* Disable “login shell over serial”
* Enable the hardware serial port for usage by applications

2. Reboot after configuration:

```bash
sudo reboot
```

3. Check which serial device is used (e.g. `/dev/serial0`, `/dev/ttyAMA0`, `/dev/ttyS0`) by:

```bash
ls -l /dev/serial*
```

6. **Troubleshooting RS-485** tips:

* Ensure serial (shell) is disabled (so it doesn’t “steal” the UART).
* Ensure correct device path (e.g. `/dev/ttyAMA0` vs `/dev/ttyS0`).
* Check A/B line polarity matches
* Match baud rate, parity, stop bits, etc. on both sides
* If communication is unstable, try lower baud rates first

---

## Loopback / Self-Test (If you have only one module)

If you only have one HAT and want to test CAN functionality:

* Use loopback mode:

  ```bash
  sudo ip link set can0 down
  sudo ip link set can0 type can bitrate 1000000 loopback on
  sudo ip link set can0 up
  ```

* Then in terminal windows:

  ```bash
  candump can0
  cansend can0 000#11.22.33.44
  ```

If it works, the sent frame should be received by itself. ([waveshare.com][1])

