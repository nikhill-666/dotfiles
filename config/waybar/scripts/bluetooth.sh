#!/bin/bash

# Use echo to pipe commands to bluetoothctl
output=$(echo "show" | bluetoothctl --timeout=2 2>&1 | grep -v "^\[" | grep -v "^$")
powered=$(echo "$output" | grep -c "Powered: yes")
[ -z "$powered" ] && powered=0

if [ "$powered" -eq 0 ]; then
    echo '{"text": "󰂲", "class": "off", "tooltip": "Bluetooth off"}'
    exit 0
fi

# Check for connected devices using 'info' (shows first connected device or nothing)
connected=$(echo "info" | bluetoothctl --timeout=2 2>&1 | grep -c "Connected: yes")
[ -z "$connected" ] && connected=0

if [ "$connected" -eq 0 ]; then
    echo '{"text": "󰂯", "class": "on", "tooltip": "Bluetooth on"}'
else
    # Get device name
    device=$(echo "info" | bluetoothctl --timeout=2 2>&1 | grep "^	Name:" | head -1 | sed 's/	Name: //')
    echo "{\"text\": \"󰥰\", \"tooltip\": \"$device\", \"class\": \"connected\"}"
fi
