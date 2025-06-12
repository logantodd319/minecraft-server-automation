#!/bin/bash

# Minecraft Server Setup Script
set -e  # Exit on error

# Variables
MINECRAFT_HOME="/opt/minecraft"
MINECRAFT_USER="minecraft"
RAM_ALLOCATION="2G"

# Update system and install dependencies
sudo apt-get update -y
sudo apt-get install -y wget screen

# Install Java using reliable method
if ! command -v java &> /dev/null; then
    echo "Installing Java from AdoptOpenJDK..."
    sudo apt-get install -y apt-transport-https ca-certificates gnupg
    sudo mkdir -p /etc/apt/keyrings
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
    sudo apt-get update -y
    sudo apt-get install -y temurin-17-jdk
fi

# Verify Java installation
java -version

# Create minecraft user and directory
sudo useradd -r -m -U -d ${MINECRAFT_HOME} -s /bin/bash ${MINECRAFT_USER}
sudo mkdir -p ${MINECRAFT_HOME}
sudo chown -R ${MINECRAFT_USER}:${MINECRAFT_USER} ${MINECRAFT_HOME}

# Download latest Minecraft server
cd ${MINECRAFT_HOME}
echo "Downloading latest Minecraft server..."
sudo -u ${MINECRAFT_USER} wget -O server.jar https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar || \
sudo -u ${MINECRAFT_USER} wget -O server.jar https://launcher.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e81d1/server.jar || \
sudo -u ${MINECRAFT_USER} wget -O server.jar https://launcher.mojang.com/v1/objects/$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r '.latest.release as $v | .versions[] | select(.id == $v) | .url' | xargs curl -s | jq -r '.downloads.server.url')

# Accept EULA
echo "eula=true" | sudo -u ${MINECRAFT_USER} tee ${MINECRAFT_HOME}/eula.txt

# Create server.properties
cat <<EOF | sudo -u ${MINECRAFT_USER} tee ${MINECRAFT_HOME}/server.properties
enable-jmx-monitoring=false
rcon.port=25575
gamemode=survival
enable-command-block=false
enable-query=false
generator-settings={}
level-name=world
motd=Terraform Minecraft Server
query.port=25565
pvp=true
generate-structures=true
difficulty=easy
network-compression-threshold=256
require-resource-pack=false
max-players=20
online-mode=true
enable-status=true
allow-flight=false
broadcast-rcon-to-ops=true
view-distance=10
server-port=25565
enable-rcon=false
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
resource-pack=
entity-broadcast-range-percentage=100
simulation-distance=10
player-idle-timeout=0
force-gamemode=false
rate-limit=0
hardcore=false
white-list=false
spawn-npcs=true
spawn-animals=true
spawn-monsters=true
enforce-whitelist=false
spawn-protection=16
max-world-size=29999984
EOF

# Create systemd service
cat <<EOF | sudo tee /etc/systemd/system/minecraft.service
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=${MINECRAFT_USER}
Group=${MINECRAFT_USER}
WorkingDirectory=${MINECRAFT_HOME}
ExecStart=/usr/bin/java -Xms${RAM_ALLOCATION} -Xmx${RAM_ALLOCATION} -jar server.jar nogui
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Install jq for JSON parsing if needed
if ! command -v jq &> /dev/null; then
    sudo apt-get install -y jq
fi

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable minecraft
sudo systemctl start minecraft

# Open firewall (if needed)
sudo ufw allow 25565/tcp

# Verify service is running
sleep 10  # Give the service time to start
sudo systemctl status minecraft
