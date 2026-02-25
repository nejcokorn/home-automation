# Raspberry Pi 5 Manual Configuration for Home Automation

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

Install Raspberry Pi config tool
```bash
sudo apt install raspi-config
```

Install build-essential
```bash
sudo apt install build-essential
```

## Configure PCI Express 3
(This is only valid when used with NVMe)  
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

Reboot system `sudo reboot` for changes to take effect

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
StandardOutput=null
Type=oneshot
ExecStart=/sbin/ip link set can0 up type can bitrate 500000 restart-ms 1000
ExecStartPost=/sbin/ip link set can0 txqueuelen 65536
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
StandardOutput=null
Type=oneshot
ExecStart=/sbin/ip link set can1 up type can bitrate 500000 restart-ms 1000
ExecStartPost=/sbin/ip link set can1 txqueuelen 65536
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

## Install Home Automation Agent and Stack

Install the Home Automation Agent:
```bash
echo "=== Install Home Automation Agent ==="
curl -fL -O https://github.com/nejcokorn/home-automation-agent/releases/download/v1.2.0/home-automation-agent_1.2.0_arm64.deb

# Install home-automation-agent_1.2.0_arm64.deb
sudo dpkg -i home-automation-agent_1.2.0_arm64.deb

# Fix broken dependencies if any
sudo apt-get -f install -y

sudo systemctl daemon-reload
sudo systemctl enable --now home-automation-agent
```

Setup the home automation stack:
```bash
echo "=== Setup home automation stack ==="
mkdir -p /home/rpi
cd /home/rpi
git clone https://github.com/nejcokorn/home-automation.git
sudo chown rpi:rpi /home/rpi -R
cd /home/rpi/home-automation
sudo -u rpi bash -c 'cd /home/rpi/home-automation && ./scripts/compose-env.sh'
```

Install HACS in Home Assistant:
```bash
echo "=== Install HACS in Home Assistant ==="
sudo -u rpi bash <<'EOF'
docker exec homeassistant bash -c '
	curl -4 -fsSL https://get.hacs.xyz | bash -
'
EOF
```

Install Node-RED packages:
```bash
echo "=== Install Node-RED packages ==="
sudo -u rpi bash <<'EOF'
docker exec nodered bash -c '
	cd /data
	npm install @home-automation/home-automation-main
	npm install node-red-contrib-sun-position
	npm install node-red-contrib-home-assistant-websocket
'
EOF
```

Restart docker services:
```bash
echo "=== Restarting docker services ==="
sudo -u rpi bash <<'EOF'
cd /home/rpi/home-automation
docker compose restart nodered
docker compose restart homeassistant
EOF
```
