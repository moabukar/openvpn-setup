# OpenVPN Server Automation

Automated setup scripts for deploying OpenVPN server with cross-platform client support.

Basically setup your own VPN server.

## Quick Start

```bash
# For Multipass testing
make multipass-test

# For production server
make install
make setup-server
make create-client CLIENT_NAME=myclient
```

## Commands

- `make install` - Install OpenVPN and dependencies
- `make setup-server` - Configure OpenVPN server
- `make create-client CLIENT_NAME=name` - Generate client config
- `make start` - Start OpenVPN service
- `make stop` - Stop OpenVPN service
- `make status` - Check service status
- `make logs` - View logs
- `make clean` - Clean up generated files

## Security

- All sensitive files are in .gitignore
- Certificates are generated locally
- No hardcoded secrets

See `docs/SETUP.md` for detailed instructions.
