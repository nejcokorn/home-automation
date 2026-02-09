#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# ================================
# Docker installation
# ================================

echo "=== Add docker offical GPG key and repository ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "=== Add docker repository to apt sources ==="
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "=== Upade system with the package list from docker repository ==="
apt update

echo "=== Install docker packages ==="
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== Add rpi user to the docker group to grant all the permissions related to docker ==="
usermod -aG docker rpi

systemctl enable docker
systemctl start docker

# ================================
# Raspberry Pi 2-CH CAN HAT setup
# ================================

CONFIG_FILE="/boot/firmware/config.txt"

echo "=== Enabling SPI via raspi-config ==="
raspi-config nonint do_spi 0

echo "=== Updating system ==="
apt-get update

echo "=== Installing required packages ==="
apt-get install -y \
	build-essential \
	unzip \
	wget \
	can-utils \
	i2c-tools \
	net-tools

echo "=== Configuring CAN overlays in config.txt ==="

if ! grep -q "mcp2515,spi1-1" "$CONFIG_FILE"; then
	cat << 'EOF' >> "$CONFIG_FILE"

[all]
# Enable CAN communication
dtparam=spi=on
dtoverlay=i2c0
dtoverlay=spi1-3cs
dtoverlay=mcp2515,spi1-1,oscillator=16000000,interrupt=22
dtoverlay=mcp2515,spi1-2,oscillator=16000000,interrupt=13
EOF
	echo "CAN overlays added to config.txt"
else
	echo "CAN overlays already present, skipping"
fi

echo "=== Installing BCM2835 library ==="
if [ ! -d "/usr/local/include/bcm2835.h" ]; then
	wget -q http://www.airspayce.com/mikem/bcm2835/bcm2835-1.75.tar.gz
	tar zxvf bcm2835-1.75.tar.gz
	cd bcm2835-1.75
	./configure
	make
	make check
	make install
	cd ..
else
	echo "BCM2835 already installed, skipping"
fi

echo "=== Installing wiringPi ==="
if ! command -v gpio >/dev/null 2>&1; then
	wget -q https://github.com/WiringPi/WiringPi/releases/download/3.18/wiringpi_3.18_arm64.deb
	dpkg -i wiringpi_3.18_arm64.deb
else
	echo "wiringPi already installed, skipping"
fi

echo "=== Creating systemd service for can0 ==="
cat << 'EOF' > /etc/systemd/system/can0.service
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
EOF

echo "=== Creating systemd service for can1 ==="
cat << 'EOF' > /etc/systemd/system/can1.service
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
EOF

echo "=== Enabling CAN services ==="
systemctl daemon-reload
systemctl enable can0.service
systemctl enable can1.service
systemctl start can0.service || true
systemctl start can1.service || true

echo "===================================="
echo " CAN setup completed successfully!"
echo " Reboot the system to apply changes."
echo "===================================="