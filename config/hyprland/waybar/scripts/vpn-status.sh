#!/bin/bash

# Ping the home DNS server to check VPN status
if ping -c 1 -W 1 192.168.1.145 >/dev/null 2>&1; then
    # VPN is up - show green target reticle
    echo '{"text": "HOME", "class": "vpn-up", "tooltip": "VPN Connected"}'
else
    # VPN is down - show red target reticle
    echo '{"text": "OFFLINE", "class": "vpn-down", "tooltip": "VPN Disconnected"}'
fi
