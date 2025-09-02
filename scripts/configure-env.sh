#!/bin/bash

# Environment configuration script
# Creates .env file with server settings

ENV_FILE=".env"

echo "Configuring environment..."

# Get server IP
SERVER_IP=$(curl -s ipinfo.io/ip 2>/dev/null || hostname -I | awk '{print $1}')

# Create .env file
cat > $ENV_FILE << EOL
# OpenVPN Server Configuration
SERVER_IP=$SERVER_IP
VPN_PORT=1194
VPN_PROTOCOL=udp
VPN_SUBNET=10.8.0.0
VPN_NETMASK=255.255.255.0

# Paths
OPENVPN_DIR=/etc/openvpn
LOG_DIR=/var/log/openvpn
CLIENT_CONFIG_DIR=/etc/openvpn/client-configs

# Security settings
CIPHER=AES-256-GCM
AUTH=SHA256
TLS_VERSION_MIN=1.2
EOL

echo "Environment configured in $ENV_FILE"
echo "Server IP detected as: $SERVER_IP"
