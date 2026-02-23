#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# ================================
# Partition and format the remaining free space on the disk
# ================================

echo "=== Partitioning and formatting remaining free space ==="

# Get root device (e.g., /dev/mmcblk0p2 or /dev/nvme0n1p2)
ROOT_PART=$(findmnt -n -o SOURCE /)

# Extract disk from partition (works for sda1, nvme0n1p2, mmcblk0p2)
if [[ "$ROOT_PART" =~ p[0-9]+$ ]]; then
	DISK=$(echo "$ROOT_PART" | sed -E 's/p[0-9]+$//')
else
	DISK=$(echo "$ROOT_PART" | sed -E 's/[0-9]+$//')
fi

# Resize root partition to 32GB
parted ---pretend-input-tty "$DISK" resizepart 2 32GiB <<< "Yes"
resize2fs "$ROOT_PART"

echo "Root filesystem is on: $ROOT_PART"
echo "Detected disk: $DISK"

# Find start of last free space block
FREE_START=$(parted $DISK unit s print free | grep 'Free Space' | tail -n1 | awk '{print $1}')

if [ -z "$FREE_START" ]; then
	echo "No free space detected on $DISK. Skipping partitioning."
else
	echo "Creating partition from sector ${FREE_START} to 100%..."

	parted -s "$DISK" mkpart primary ext4 "${FREE_START}" 100%

	partprobe "$DISK"
	sleep 2

	# Get last partition name
	NEW_PART=$(lsblk -ln -o NAME "$DISK" | tail -n1)
	NEW_PART="/dev/$NEW_PART"

	echo "Formatting $NEW_PART..."

	mkfs.ext4 -F -L data "$NEW_PART"

	echo "Done. Created and formatted: $NEW_PART"

# ================================
# Migrate /home/rpi to the new partition
# ================================

	echo "=== Migrating /home/rpi to new partition ==="

	TMP_MOUNT="/mnt/new_home"
	FINAL_MOUNT="/home/rpi"

	echo "Preparing migration of $FINAL_MOUNT..."

	mkdir -p "$TMP_MOUNT"

	echo "Temporarily mounting $NEW_PART..."
	mount "$NEW_PART" "$TMP_MOUNT"

	echo "Copying existing data..."
	rsync -aAX "$FINAL_MOUNT"/ "$TMP_MOUNT"/

	echo "Updating /etc/fstab..."
	cp /etc/fstab /etc/fstab.backup
	echo "LABEL=data	/home/rpi	ext4	defaults,noatime	0	2" >> /etc/fstab

	echo "Unmounting temporary mount..."
	umount "$TMP_MOUNT"

	echo "Mounting new /home/rpi..."
	mount "$FINAL_MOUNT"

	echo "Migration complete."
fi

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
ExecStart=/sbin/ip link set can0 up type can bitrate 500000 restart-ms 100
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
ExecStart=/sbin/ip link set can1 up type can bitrate 500000 restart-ms 100
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
dpkg -i home-automation-agent_1.2.0_arm64.deb

# Fix broken dependencies if any
apt-get -f install -y

systemctl daemon-reload
systemctl enable --now home-automation-agent

#===================================="
# Install VS Code Server
#===================================="

echo "=== Installing VS Code Server ==="

export HOME=/home/rpi
export USER=rpi
curl -fsSL https://code-server.dev/install.sh | sh

# Create config.yaml for code-server with password authentication and no TLS
echo "=== Creating code-server config file ==="

# create config directory if it doesn't exist and set ownership to rpi
mkdir -p /home/rpi/.config/code-server
chmod 755 /home/rpi/.config
chmod 755 /home/rpi/.config/code-server
chown -R rpi:rpi /home/rpi/.config

cat <<EOF > "/home/rpi/.config/code-server/config.yaml"
bind-addr: 0.0.0.0:8080
auth: password
password: changeme
cert: false
EOF

# Enable and start code-server for the rpi user
echo "=== Enabling and starting code-server for rpi user ==="
systemctl enable --now code-server@rpi

#===================================="
# Setup home automation stack
#===================================="

echo "=== Setup home automation stack ==="

mkdir -p /home/rpi
cd /home/rpi
git clone https://github.com/nejcokorn/home-automation.git
chown rpi:rpi /home/rpi -R
cd /home/rpi/home-automation
sudo -u rpi bash -c 'cd /home/rpi/home-automation && ./scripts/configure.sh'
sudo -u rpi bash -c 'cd /home/rpi/home-automation && docker compose up -d'

echo "=== Install HACS in Home Assistant ==="
sudo -u rpi bash <<'EOF'
# Wait for Home Assistant to initialize its config directory.
for i in {1..60}; do
	if docker exec homeassistant bash -c 'test -f /config/configuration.yaml'; then
		break
	fi
	sleep 5
done
# Install HACS in Home Assistant
docker exec homeassistant bash -c '
	cd /config
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
