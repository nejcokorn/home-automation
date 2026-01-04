# Raspberry Pi 5 System Configuration for Home Automation

## Personal Computer
1. Download `rpi-imager` as described on the offical Raspberry Pi Web page - https://www.raspberrypi.com/software/
2. Install `Ubuntu Desktop 24.04.3 LTS (64-bit)` to the SD card
3. Mount SD card to Raspberry Pi 5 and start the device

## Raspberry Pi - Ubuntu Desktop on SD card
After booting from SD card use `rpi-imager` to install `Ubuntu Server 24.04.3 LTS (64-bit)` on NVMe
Install rpi-imager
```bash
sudo apt install rpi-imager
```
Run rpi-imager
```bash
sudo rpi-imager
```
Install `Ubuntu Desktop 24.04.3 LTS (64-bit)` on the NVMe Volume and set the user, hostname and SSH using rpi-imager through rpi-imager GUI

Remove SD card from Raspberry Pi and reboot into NVMe

## Raspberry Pi - Ubuntu Server on NVMe
Update system packages
```bash
sudo apt update
sudo apt upgrade
```

Install net tools
```bash
sudo apt install net-tools
```

Install ssh
```bash
sudo apt install ssh
```

Install Raspi config
```bash
sudo apt install raspi-config
```

Install build-essential
```bash
sudo apt install build-essential
```

Reboot and switch back to the Raspberry Pi Ubuntu Desktop installed on SD card

## Raspberry Pi - Ubuntu Desktop on SD Card
1. Resize root volume to 50GB using utility `disks`  
2. With the rest of the volume create new partition and lable it `data`
3. Remove SD card and boot into Ubuntu Server on Raspberry Pi NVMe and connect over the SSH from PC

All other tasks can be using Personal Computer connected to Raspberry Pi over SSH

# Raspberry Pi 5 Operating System Configuration for Home Automation
## Configure NVMe data partition
Create `data` directory in root directory
```bash
sudo mkdir /data
sudo chmod 777 /data
```

Mount `data` partition to `/etc/fstab`
```bash
LABEL=writable	/	ext4	defaults	0	1
LABEL=data	/data	ext4    defaults        0       1
LABEL=system-boot	/boot/firmware	vfat	defaults	0	1
```

Run `mount -a` to mount this new partition.

## Configure PCI Express 3
Modify `sudo nano /boot/firmware/config.txt` and add parameters at the end of the file to setup PCI Express using version 3.0
```bash
[all]
# Enable PCI Express 3
dtparam=pciex1
dtparam=pciex1_gen=3
```
Reboot system `sudo reboot` for changes to take effect

### Test PCI Express 3
Run below command and make sure PCI Express is running in full speed.
```bash
sudo lspci -vv -s 01:00.0
```
Look for `LnkSta: Speed 8GT/s, Width x1 (downgraded)`

### Speed test Solid State Drive using PCI Express
Make sure you are getting expected results
```bash
sudo dd if=/dev/zero of=/mnt/test.img bs=1G count=4 oflag=direct status=progress
```

## Install Docker for Ubuntu
### Add Docker's official GPG key:
```bash
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

### Add the repository to apt sources:
```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

Upade system with the package list from docker repository
```bash
sudo apt update
```

Install docker packages
```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Add `rpi` user to the `docker` group to grant all the permissions related to docker
```bash
sudo usermod -aG docker rpi
```

## Configure 1-Wire
Modify `/boot/firmware/config.txt` and add parameters to the end of the file to enable 1-Wire communication
```bash
[all]
# Enable 1-Wire communication
dtoverlay=w1-gpio
```

Reboot system `sudo reboot` for changes to take effect

## Configure CAN
Offical documentation - https://www.waveshare.com/wiki/2-CH_CAN_HAT+

### Preparation
```bash
sudo raspi-config
```
Select Interfacing Options -> SPI -> Yes to enable SPI interface 

Reboot system `sudo reboot` for changes to take effect

### Configure Raspberry Pi module for CAN
Edit `sudo nano /boot/firmware/config.txt` and add parameters at the end of the file to setup CAN
```bash
[all]
# Enable CAN communication
dtparam=spi=on
dtoverlay=i2c0 
dtoverlay=spi1-3cs
dtoverlay=mcp2515,spi1-1,oscillator=16000000,interrupt=22
dtoverlay=mcp2515,spi1-2,oscillator=16000000,interrupt=13
```

### Libraries
#### BCM2835
Install BCM2835, open the Raspberry Pi terminal, and run the following commands:
```bash
wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.75.tar.gz
tar zxvf bcm2835-1.75.tar.gz
cd bcm2835-1.75/
sudo ./configure
sudo make
sudo make check
sudo make install
```
For More: http://www.airspayce.com/mikem/bcm2835/

#### wiringPi
```bash
wget https://files.waveshare.com/upload/8/8c/WiringPi-master.zip
sudo apt-get install unzip
unzip WiringPi-master.zip
cd WiringPi-master/
chmod +x ./build
sudo ./build 
```

### Tools
Install can CLI tools
```bash
sudo apt-get install can-utils
```

### Setup can service

Insert the following content into `sudo nano /etc/systemd/system/can0.service` for can0
```ini
[Unit]
Description=Set up can0 interface
Requires=network.target
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ip link set can0 up type can bitrate 500000
ExecStartPost=/sbin/ifconfig can0 txqueuelen 65536
ExecStop=/sbin/ip link set can0 down
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Save the file, then enable and start the service:

```bash
sudo systemctl enable can0.service
sudo systemctl start can0.service
```

Insert the following content into `sudo nano /etc/systemd/system/can1.service` for can1

```ini
[Unit]
Description=Set up can1 interface
Requires=network.target
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ip link set can1 up type can bitrate 500000
ExecStartPost=/sbin/ifconfig can1 txqueuelen 65536
ExecStop=/sbin/ip link set can1 down
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Save the file, then enable and start the service:

```bash
sudo systemctl enable can1.service
sudo systemctl start can1.service
```