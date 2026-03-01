#!/bin/bash

CONFIG_DIR="$HOME/.config/waybar"

# Kill existing Waybar
pkill -f waybar
sleep 2

case "$1" in
    "standard")
        echo "Starting standard config..."
        waybar -c "$CONFIG_DIR/config.jsonc" -s "$CONFIG_DIR/style.css" &
        ;;
    "simple"|"chill")
        echo "Starting simple config..."
        waybar -c "$CONFIG_DIR/config-simple.jsonc" -s "$CONFIG_DIR/style-simple.css" &
        ;;
    *)
        echo "Usage: $0 {standard|simple|chill}"
        exit 1
        ;;
esac