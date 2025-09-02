#!/bin/bash

# Client configuration generator
# Usage: ./generate-client-config.sh <client_name>

CLIENT_NAME="$1"
KEY_DIR="/etc/openvpn/easy-rsa/pki"
OUTPUT_DIR="/etc/openvpn/client-configs/files"
BASE_CONFIG="/etc/openvpn/client-configs/base.conf"

if [ -z "$CLIENT_NAME" ]; then
    echo "Usage: $0 <client_name>"
    exit 1
fi

if [ ! -f "${KEY_DIR}/issued/${CLIENT_NAME}.crt" ]; then
    echo "Error: Certificate for $CLIENT_NAME not found"
    exit 1
fi

echo "Generating configuration for: $CLIENT_NAME"

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/issued/${CLIENT_NAME}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/private/${CLIENT_NAME}.key \
    <(echo -e '</key>\n<tls-auth>') \
    /etc/openvpn/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${CLIENT_NAME}.ovpn

echo "Client configuration generated: ${OUTPUT_DIR}/${CLIENT_NAME}.ovpn"
