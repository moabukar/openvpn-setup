#!/bin/bash

# OpenVPN monitoring script

print_status() {
    echo "=== OpenVPN Server Status ==="
    systemctl is-active openvpn@server && echo "✓ Service is running" || echo "✗ Service is not running"
    echo ""
    
    echo "=== Connected Clients ==="
    if [ -f /var/log/openvpn/openvpn-status.log ]; then
        grep "CLIENT_LIST" /var/log/openvpn/openvpn-status.log | while IFS=',' read -r _ name real_ip virtual_ip _ connected_since bytes_recv bytes_sent _; do
            if [ "$name" != "HEADER" ]; then
                echo "Client: $name"
                echo "  Real IP: $real_ip"
                echo "  Virtual IP: $virtual_ip"
                echo "  Connected: $connected_since"
                echo "  Data: ↓$(numfmt --to=iec $bytes_recv) ↑$(numfmt --to=iec $bytes_sent)"
                echo ""
            fi
        done
    else
        echo "No status log found"
    fi
}

watch_logs() {
    echo "Watching OpenVPN logs (Press Ctrl+C to stop)..."
    tail -f /var/log/openvpn/openvpn.log
}

case "$1" in
    "status")
        print_status
        ;;
    "logs")
        watch_logs
        ;;
    *)
        echo "Usage: $0 {status|logs}"
        echo "  status - Show server and client status"
        echo "  logs   - Watch live logs"
        ;;
esac
