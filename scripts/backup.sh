#!/bin/bash

# Backup OpenVPN configuration and certificates

BACKUP_DIR="backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup in: $BACKUP_DIR"

# Backup certificates (excluding private keys for security)
cp /etc/openvpn/ca.crt "$BACKUP_DIR/"
cp /etc/openvpn/server.crt "$BACKUP_DIR/"
cp /etc/openvpn/dh.pem "$BACKUP_DIR/"

# Backup configuration
cp /etc/openvpn/server.conf "$BACKUP_DIR/"
cp /etc/openvpn/client-configs/base.conf "$BACKUP_DIR/client-base.conf"

# Backup client list
if [ -f /var/log/openvpn/ipp.txt ]; then
    cp /var/log/openvpn/ipp.txt "$BACKUP_DIR/"
fi

# Create backup info
cat > "$BACKUP_DIR/README.txt" << EOL
OpenVPN Backup Created: $(date)
Server IP: $(curl -s ipinfo.io/ip 2>/dev/null || hostname -I | awk '{print $1}')

Files included:
- ca.crt: Certificate Authority
- server.crt: Server certificate
- dh.pem: Diffie-Hellman parameters
- server.conf: Server configuration
- client-base.conf: Client configuration template
- ipp.txt: Client IP assignments (if exists)

Note: Private keys are not included in backups for security.
To restore, copy files back to /etc/openvpn/ and restart service.
EOL

echo "Backup created successfully in: $BACKUP_DIR"
echo "Private keys are NOT included in backup for security"
