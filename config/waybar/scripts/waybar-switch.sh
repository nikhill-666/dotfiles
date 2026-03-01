#!/bin/bash

CONFIG_DIR="$HOME/.config/waybar"
STATE_FILE="$CONFIG_DIR/.current_mode"

# Get current mode or default to standard
get_current_mode() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo "standard"
    fi
}

# Kill Waybar instances safely
kill_waybar() {
    pkill -x waybar 2>/dev/null || true
    sleep 1
}

# Start Waybar with specific config
start_waybar() {
    local mode="$1"
    case "$mode" in
        "standard")
            waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &
            ;;
        "simple"|"chill")
            waybar -c ~/.config/waybar/config-simple.jsonc -s ~/.config/waybar/style-simple.css &
            ;;
    esac
}

# Main logic
case "$1" in
    "standard")
        kill_waybar
        echo "standard" > "$STATE_FILE"
        echo "Switched to standard Waybar config"
        start_waybar "standard"
        ;;
    "simple"|"chill")
        kill_waybar
        echo "simple" > "$STATE_FILE"
        echo "Switched to simple/chill Waybar config"
        start_waybar "simple"
        ;;
    "toggle")
        current=$(get_current_mode)
        if [[ "$current" == "simple" ]]; then
            "$0" "standard"
        else
            "$0" "simple"
        fi
        ;;
    "")
        # If no argument, show status
        current=$(get_current_mode)
        echo "Current mode: $current"
        if pgrep -x waybar > /dev/null; then
            echo "Currently running Waybar processes:"
            ps aux | grep waybar | grep -v grep
        else
            echo "No Waybar processes running"
        fi
        ;;
    *)
        echo "Usage: $0 {standard|simple|chill|toggle}"
        echo "  standard - Switch to full config"
        echo "  simple/chill - Switch to minimal config"
        echo "  toggle - Switch between configs"
        exit 1
        ;;
esac