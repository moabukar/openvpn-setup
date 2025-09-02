#!/bin/bash
set -e

CLIENT_NAME="$1"

if [ -z "$CLIENT_NAME" ]; then
    echo "Usage: $0 <client_name>"
    exit 1
fi

echo "Revoking client certificate for: $CLIENT_NAME"

cd /etc/openvpn/easy-rsa

# Revoke certificate
./easyrsa revoke "$CLIENT_NAME"

# Generate CRL
./easyrsa gen-crl

# Copy CRL to OpenVPN directory
cp pki/crl.pem /etc/openvpn/

# Add CRL to server config if not already present
if ! grep -q "crl-verify" /etc/openvpn/server.conf; then
    echo "crl-verify crl.pem" >> /etc/openvpn/server.conf
fi

# Restart OpenVPN to apply changes
systemctl restart openvpn@server

echo "Client $CLIENT_NAME revoked successfully"
echo "Restart required - OpenVPN service has been restarted"
