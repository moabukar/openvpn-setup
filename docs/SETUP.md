# OpenVPN Server Setup Documentation

## Quick Start

1. **Test Environment (Recommended First)**

```bash
make multipass-test
```

2. **Production Server**

```bash
make install
make setup-server
make create-client CLIENT_NAME=myclient
```

## Detailed Setup

### Prerequisites

- Ubuntu 20.04+ or similar Linux distribution
- Root or sudo access
- Public IP address (for production)

### Installation Steps

1. **Clone and Setup**

```bash
git clone https://github.com/moabukar/openvpn-setup.git
cd openvpn-setup
./scripts/quickstart.sh
```

2. **Create Client Configurations**

```bash
make create-client CLIENT_NAME=laptop
make create-client CLIENT_NAME=phone
```

3. **Transfer Client Configs**

```bash
# Files will be in clients/ directory
ls clients/
```

### Client Connection

#### macOS

1. Install Tunnelblick from https://tunnelblick.net/ or viscosity. 
2. Import the `.ovpn` file
3. Connect

#### Windows

1. Install OpenVPN GUI from https://openvpn.net/
2. Copy `.ovpn` file to `C:\Program Files\OpenVPN\config\`
3. Connect via system tray icon

#### Linux

```bash
sudo openvpn --config client.ovpn
```

#### iOS/Android

1. Install "OpenVPN Connect" app
2. Import `.ovpn` file via email or file transfer

### Troubleshooting

#### Connection Issues

```bash
# Check service status
make status

# View logs
make logs

# Restart service
systemctl restart openvpn@server
```

#### Firewall Issues

```bash
# Check UFW status
sudo ufw status verbose

# Reset UFW if needed
sudo ufw --force reset
sudo ufw allow ssh
sudo ufw allow 1194/udp
sudo ufw --force enable
```

### Security Considerations

- Certificates are valid for 10 years by default
- Change default port for additional security
- Use fail2ban for intrusion prevention
- Regularly update server packages
- Monitor connection logs
- Revoke compromised client certificates

### Performance Tuning

For high-traffic servers, consider:
- Increasing client limits
- Using TCP instead of UDP for reliability
- Adjusting buffer sizes
- Using hardware acceleration if available
