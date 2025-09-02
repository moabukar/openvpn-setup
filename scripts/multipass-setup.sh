#!/bin/bash
set -e

VM_NAME="openvpn-test"

echo "Setting up OpenVPN test environment with Multipass..."

# Check if Multipass is installed
if ! command -v multipass &> /dev/null; then
    echo "Multipass is not installed. Please install it first:"
    echo "  macOS: brew install --cask multipass"
    echo "  Linux: snap install multipass"
    exit 1
fi

# Create VM if it doesn't exist
if ! multipass list | grep -q "$VM_NAME"; then
    echo "Creating Multipass VM: $VM_NAME"
    multipass launch --name "$VM_NAME" --cpus 2 --memory 2G --disk 10G 22.04
else
    echo "VM $VM_NAME already exists"
fi

# Get VM IP
VM_IP=$(multipass list | grep "$VM_NAME" | awk '{print $3}')
echo "VM IP: $VM_IP"

# Transfer project files to VM
echo "Transferring project files to VM..."
multipass transfer . "$VM_NAME:/home/ubuntu/openvpn-server"

# Setup server in VM
echo "Setting up OpenVPN server in VM..."
multipass exec "$VM_NAME" -- bash -c "cd /home/ubuntu/openvpn-server && make install && make setup-server"

echo ""
echo "Multipass OpenVPN server setup complete!"
echo "VM Name: $VM_NAME"
echo "VM IP: $VM_IP"
echo ""
echo "To create a client config:"
echo "  multipass exec $VM_NAME -- bash -c 'cd /home/ubuntu/openvpn-server && make create-client CLIENT_NAME=test'"
echo ""
echo "To get client config file:"
echo "  multipass transfer $VM_NAME:/home/ubuntu/openvpn-server/clients/test.ovpn ./test.ovpn"
echo ""
echo "To access VM:"
echo "  multipass shell $VM_NAME"
