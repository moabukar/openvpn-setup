#!/bin/bash
set -e

CLIENT_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -z "$CLIENT_NAME" ]; then
    echo "Usage: $0 <client_name>"
    exit 1
fi

echo "Creating client configuration for: $CLIENT_NAME"

cd /etc/openvpn/easy-rsa

# Generate client certificate
if [ ! -f "pki/issued/${CLIENT_NAME}.crt" ]; then
    echo "Generating certificate for $CLIENT_NAME..."
    ./easyrsa gen-req "$CLIENT_NAME" nopass
    ./easyrsa sign-req client "$CLIENT_NAME"
fi

# Generate client config
echo "Generating client configuration..."
/etc/openvpn/client-configs/make_config.sh "$CLIENT_NAME"

# Copy to project clients directory
cp "/etc/openvpn/client-configs/files/${CLIENT_NAME}.ovpn" "$PROJECT_DIR/clients/"

echo "Client configuration created:"
echo "  - Certificate: pki/issued/${CLIENT_NAME}.crt"
echo "  - Config file: clients/${CLIENT_NAME}.ovpn"
echo ""
echo "To connect from different devices:"
echo "  - macOS: Install Tunnelblick, import ${CLIENT_NAME}.ovpn"
echo "  - Windows: Install OpenVPN GUI, copy to config folder"
echo "  - Linux: sudo openvpn --config clients/${CLIENT_NAME}.ovpn"
echo "  - iOS/Android: Install OpenVPN Connect app, import config"
