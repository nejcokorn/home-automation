#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# ================================
# Docker installation
# ================================

echo "=== Update apt cache and install prerequisites ==="
apt-get update
apt-get install -y ca-certificates curl
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
apt-get update

echo "=== Install docker packages ==="
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== Add rpi user to the docker group to grant all the permissions related to docker ==="
usermod -aG docker rpi

systemctl enable docker
systemctl start docker

# ================================
# Configure PCI Express 3, 1-Wire and CAN in config.txt
# ================================
echo "=== Configuring PCI Express 3, 1-Wire and CAN in config.txt ==="
sudo tee -a "/boot/firmware/config.txt" > /dev/null << 'EOF'
# Enable PCI Express 3
dtparam=pciex1
dtparam=pciex1_gen=3

# Enable 1-Wire communication
dtoverlay=w1-gpio

# Enable CAN communication
dtoverlay=i2c0
dtoverlay=spi1-3cs
dtoverlay=mcp2515,spi1-2,oscillator=16000000,interrupt=13
dtoverlay=mcp2515,spi1-1,oscillator=16000000,interrupt=22
EOF

# ================================
# Raspberry Pi 2-CH CAN HAT setup
# ================================

echo "=== Installing can-utils ==="
apt-get install can-utils

echo "=== Creating systemd service for can0 ==="
cat << 'EOF' > /etc/systemd/system/can0.service
[Unit]
Description=Set up can0 interface
Requires=network.target
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ip link set can0 up type can bitrate 500000
ExecStartPost=/sbin/ip link set can0 txqueuelen 65536
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
ExecStartPost=/sbin/ip link set can1 txqueuelen 65536
ExecStop=/sbin/ip link set can1 down
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "=== Enabling CAN services ==="
systemctl daemon-reload
systemctl enable can0.service
systemctl enable can1.service
systemctl start can0.service || echo "can0 is not available yet"
systemctl start can1.service || echo "can1 is not available yet"

#===================================="
# Install home automation agent
#===================================="

echo "=== Install Home Automation Agent ==="

curl -fL -O https://github.com/nejcokorn/home-automation-agent/releases/download/v1.2.0/home-automation-agent_1.2.0_arm64.deb

# Install home-automation-agent_1.2.0_arm64.deb
sudo dpkg -i home-automation-agent_1.2.0_arm64.deb

# Fix broken dependencies if any
apt-get -f install -y

sudo systemctl daemon-reload
sudo systemctl enable --now home-automation-agent

#===================================="
# Setup home automation stack
#===================================="

echo "=== Setup home automation stack ==="

mkdir -p /home/rpi
cd /home/rpi
git clone https://github.com/nejcokorn/home-automation.git
chown rpi:rpi /home/rpi -R
cd /home/rpi/home-automation
sudo -u rpi bash -c 'cd /home/rpi/home-automation && ./scripts/compose-env.sh'

echo "=== Install HACS in Home Assistant ==="
sudo -u rpi bash <<'EOF'
docker exec homeassistant bash -c '
	curl -4 -fsSL https://get.hacs.xyz | bash -
'
EOF

echo "=== Install Node-RED packages ==="
sudo -u rpi bash <<'EOF'
docker exec nodered bash -c '
	cd /data
	npm install @home-automation/home-automation-main
	npm install node-red-contrib-sun-position
	npm install node-red-contrib-home-assistant-websocket
'
EOF

echo "=== Restarting docker services ==="
sudo -u rpi bash <<'EOF'
cd /home/rpi/home-automation
docker compose restart nodered
docker compose restart homeassistant
EOF

#===================================="
# Reboot system to apply all changes
#===================================="
reboot
