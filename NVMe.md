# Raspberry Pi 5 Home Automation on NVMe

Goal: Use the SD card only to boot and run `rpi-imager`, then install the final OS to the NVMe drive.

You will:
1. Flash `Ubuntu Desktop 24.04.3 LTS (64-bit)` to an SD card.
2. Boot the Raspberry Pi 5 from the SD card.
3. Use `rpi-imager` on the Pi to flash the NVMe drive with the final OS image.
4. Copy cloud-init (`user-data`, `meta-data`, `network-config`) files from this repo to the NVMe boot volume.
5. Remove the SD card and boot from NVMe.

## Install Ubuntu Desktop on SD Card
1. Download `rpi-imager` from the official Raspberry Pi website.
2. Use `rpi-imager` to flash `Ubuntu Desktop 24.04.3 LTS (64-bit)` to the SD card.
3. Insert the SD card into the Raspberry Pi 5 and boot.

## Raspberry Pi - Ubuntu Desktop on SD Card
1. After booting from the SD card, install `rpi-imager` if it is not already installed:
```bash
sudo apt install rpi-imager
```
2. Run `rpi-imager`:
```bash
sudo rpi-imager
```
3. Use `rpi-imager` to flash the NVMe drive with:
   `Ubuntu Server 24.04.3 LTS (64-bit)`
4. Mount the NVMe boot volume and replace `cloud-init` files from this repository in boot volume on NVMe:
   `user-data`, `meta-data`, `network-config`
5. Power off, remove the SD card, and boot from NVMe.
