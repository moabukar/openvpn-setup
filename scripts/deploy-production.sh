#!/bin/bash
set -e

echo "OpenVPN Production Deployment"
echo "============================="
echo ""

# Detect environment
if command -v multipass &> /dev/null && multipass list | grep -q "openvpn-test"; then
    echo "Multipass test environment detected."
    echo "To deploy to production server:"
    echo ""
    echo "1. Copy this project to your server:"
    echo "   scp -r . user@your-server:/path/to/openvpn-server"
    echo ""
    echo "2. SSH to your server and run:"
    echo "   cd /path/to/openvpn-server"
    echo "   make install"
    echo "   make setup-server"
    echo ""
    echo "3. Create client configs:"
    echo "   make create-client CLIENT_NAME=yourclient"
    echo ""
    echo "4. Download client configs:"
    echo "   scp user@your-server:/path/to/openvpn-server/clients/yourclient.ovpn ."
    exit 0
fi

# Check if running on server
echo "Configuring for production deployment..."

# Security hardening for production
echo "Applying production security settings..."

# Change to a less obvious port (optional)
read -p "Change default port 1194 to 443 for better compatibility? [y/N]: " change_port
if [[ $change_port =~ ^[Yy]$ ]]; then
    sed -i 's/port 1194/port 443/' /etc/openvpn/server.conf
    sed -i 's/1194/443/' /etc/openvpn/client-configs/base.conf
    ufw delete allow 1194/udp
    ufw allow 443/udp
    echo "Port changed to 443"
fi

# Install fail2ban for additional security
if ! command -v fail2ban-client &> /dev/null; then
    echo "Installing fail2ban for additional security..."
    apt install -y fail2ban
    
    # Create OpenVPN fail2ban jail
    cat > /etc/fail2ban/jail.d/openvpn.conf << EOL
[openvpn]
enabled = true
port = 1194
protocol = udp
filter = openvpn
logpath = /var/log/openvpn/openvpn.log
maxretry = 3
bantime = 3600
EOL
    
    systemctl enable fail2ban
    systemctl restart fail2ban
fi

# Restart OpenVPN with new settings
systemctl restart openvpn@server

echo ""
echo "Production deployment complete!"
echo "Server is ready for client connections"
