#!/bin/bash
set -e

echo "Installing OpenVPN and dependencies..."

# Update system
apt update && apt upgrade -y

# Install required packages
apt install -y openvpn easy-rsa iptables-persistent ufw curl

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' | tee -a /etc/sysctl.conf
sysctl -p

# Create directories
mkdir -p /var/log/openvpn
mkdir -p /etc/openvpn/client-configs/files

echo "Installation completed successfully!"
