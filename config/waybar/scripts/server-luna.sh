#!/bin/bash

STATE_FILE="/tmp/luna_server_state"
SERVER_NAME="luna.lan"
SERVER_IP="192.168.1.210"

# Check current server status
if ping -c 1 -W 1 "$SERVER_IP" >/dev/null 2>&1; then
    current_state="up"
    text="🟢"
    class="server-up"
    tooltip="$SERVER_NAME ($SERVER_IP) - UP"
else
    current_state="down"
    text="🔴"
    class="server-down"
    tooltip="$SERVER_NAME ($SERVER_IP) - DOWN"
fi

# Read previous state
if [ -f "$STATE_FILE" ]; then
    previous_state=$(cat "$STATE_FILE")
else
    previous_state="unknown"
fi

# Send notification on state change
if [ "$previous_state" != "$current_state" ] && [ "$previous_state" != "unknown" ]; then
    if [ "$current_state" = "down" ]; then
        notify-send -u critical "Server Down" "$SERVER_NAME ($SERVER_IP) is no longer responding" --icon=network-error
    else
        notify-send -u normal "Server Up" "$SERVER_NAME ($SERVER_IP) is back online" --icon=network-idle
    fi
fi

# Save current state
echo "$current_state" > "$STATE_FILE"

# Output JSON for Waybar
echo "{\"text\": \"$text\", \"class\": \"$class\", \"tooltip\": \"$tooltip\"}"