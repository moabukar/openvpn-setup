.PHONY: help install setup-server create-client start stop status logs clean multipass-test

# Default target
help:
	@echo "OpenVPN Server Automation"
	@echo ""
	@echo "Available targets:"
	@echo "  install       - Install OpenVPN and dependencies"
	@echo "  setup-server  - Configure OpenVPN server"
	@echo "  create-client - Create client config (requires CLIENT_NAME=name)"
	@echo "  start         - Start OpenVPN service"
	@echo "  stop          - Stop OpenVPN service"
	@echo "  status        - Check service status"
	@echo "  logs          - View OpenVPN logs"
	@echo "  clean         - Clean up generated files"
	@echo "  multipass-test - Create test environment in Multipass"
	@echo ""
	@echo "Example: make create-client CLIENT_NAME=laptop"

install:
	@echo "Installing OpenVPN and dependencies..."
	@sudo ./scripts/install.sh

setup-server:
	@echo "Setting up OpenVPN server..."
	@sudo ./scripts/setup-server.sh

create-client:
	@if [ -z "$(CLIENT_NAME)" ]; then \
		echo "Error: CLIENT_NAME is required. Usage: make create-client CLIENT_NAME=myclient"; \
		exit 1; \
	fi
	@echo "Creating client configuration for $(CLIENT_NAME)..."
	@sudo ./scripts/create-client.sh $(CLIENT_NAME)

start:
	@echo "Starting OpenVPN server..."
	@sudo systemctl start openvpn@server
	@sudo systemctl status openvpn@server --no-pager

stop:
	@echo "Stopping OpenVPN server..."
	@sudo systemctl stop openvpn@server

status:
	@sudo systemctl status openvpn@server --no-pager

logs:
	@sudo tail -f /var/log/openvpn/openvpn.log

clean:
	@echo "Cleaning up generated files..."
	@sudo rm -rf /etc/openvpn/easy-rsa/pki
	@sudo rm -f /etc/openvpn/*.crt /etc/openvpn/*.key /etc/openvpn/*.pem /etc/openvpn/ta.key
	@sudo rm -f clients/*.ovpn
	@echo "Cleaned up certificates and keys"

multipass-test:
	@echo "Creating Multipass test environment..."
	@./scripts/multipass-setup.sh

# Server management
restart: stop start

reload:
	@sudo systemctl reload openvpn@server

# Client management
list-clients:
	@echo "Connected clients:"
	@sudo cat /var/log/openvpn/openvpn-status.log 2>/dev/null | grep "CLIENT_LIST" || echo "No clients connected"

revoke-client:
	@if [ -z "$(CLIENT_NAME)" ]; then \
		echo "Error: CLIENT_NAME is required. Usage: make revoke-client CLIENT_NAME=myclient"; \
		exit 1; \
	fi
	@sudo ./scripts/revoke-client.sh $(CLIENT_NAME)
