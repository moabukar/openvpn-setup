#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Setting up OpenVPN server..."

# Setup Easy-RSA
if [ ! -d "/etc/openvpn/easy-rsa" ]; then
    mkdir -p /etc/openvpn/easy-rsa
    cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
fi

cd /etc/openvpn/easy-rsa

# Initialize PKI if not exists
if [ ! -d "pki" ]; then
    echo "Initializing PKI..."
    ./easyrsa init-pki
    
    # Build CA
    echo "Building Certificate Authority..."
    expect << 'EOD'
spawn ./easyrsa build-ca nopass
expect "Common Name"
send "OpenVPN-CA\r"
expect eof
EOD
    
    # Generate server certificate
    echo "Generating server certificate..."
    ./easyrsa gen-req server nopass
    ./easyrsa sign-req server server
    
    # Generate DH parameters
    echo "Generating Diffie-Hellman parameters (this may take a while)..."
    ./easyrsa gen-dh
    
    # Generate TLS auth key
    openvpn --genkey --secret pki/ta.key
fi

# Copy certificates to OpenVPN directory
cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/
cp pki/ta.key /etc/openvpn/

# Get server IP
SERVER_IP=$(curl -s ipinfo.io/ip || hostname -I | awk '{print $1}')

# Copy server configuration
cp "$PROJECT_DIR/configs/server.conf" /etc/openvpn/

# Setup client config template
cp "$PROJECT_DIR/templates/client-base.conf" /etc/openvpn/client-configs/base.conf
sed -i "s/YOUR_SERVER_IP/$SERVER_IP/" /etc/openvpn/client-configs/base.conf

# Copy client generation script
cp "$PROJECT_DIR/scripts/generate-client-config.sh" /etc/openvpn/client-configs/make_config.sh
chmod +x /etc/openvpn/client-configs/make_config.sh

# Configure firewall
echo "Configuring firewall..."

# Get primary network interface
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

# Configure UFW for OpenVPN
ufw allow 1194/udp
ufw allow ssh

# Setup NAT rules for UFW
if ! grep -q "START OPENVPN RULES" /etc/ufw/before.rules; then
    # Backup original rules
    cp /etc/ufw/before.rules /etc/ufw/before.rules.backup
    
    # Add NAT rules
    sed -i '1i# START OPENVPN RULES' /etc/ufw/before.rules
    sed -i '2i# NAT table rules' /etc/ufw/before.rules
    sed -i '3i*nat' /etc/ufw/before.rules
    sed -i '4i:POSTROUTING ACCEPT [0:0]' /etc/ufw/before.rules
    sed -i "5i-A POSTROUTING -s 10.8.0.0/8 -o $INTERFACE -j MASQUERADE" /etc/ufw/before.rules
    sed -i '6iCOMMIT' /etc/ufw/before.rules
    sed -i '7i# END OPENVPN RULES' /etc/ufw/before.rules
    sed -i '8i' /etc/ufw/before.rules
fi

# Set UFW forwarding policy
sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw

# Enable UFW
ufw --force enable

# Enable and start OpenVPN
systemctl enable openvpn@server
systemctl start openvpn@server

echo "OpenVPN server setup completed!"
echo "Server IP: $SERVER_IP"
echo "Check status with: systemctl status openvpn@server"
