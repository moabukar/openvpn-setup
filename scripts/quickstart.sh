#!/bin/bash

echo "OpenVPN Quick Start"
echo "=================="
echo ""
echo "Choose your deployment option:"
echo "1) Test with Multipass (recommended first)"
echo "2) Install on current server"
echo "3) Show help"
echo ""

read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo "Starting Multipass test environment..."
        make multipass-test
        ;;
    2)
        echo "Installing on current server..."
        echo "This will install OpenVPN on this machine."
        read -p "Continue? [y/N]: " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            make install
            make setup-server
            echo ""
            echo "Server setup complete! Create a client with:"
            echo "  make create-client CLIENT_NAME=myclient"
        fi
        ;;
    3)
        make help
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
