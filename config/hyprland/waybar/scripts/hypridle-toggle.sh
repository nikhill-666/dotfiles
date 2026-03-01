#!/bin/bash

# Hypridle toggle script for Waybar

case "${1:-status}" in
    "toggle")
        if pgrep -x hypridle > /dev/null 2>&1; then
            # hypridle is running, stop it
            pkill -x hypridle
            sleep 0.5
            echo '{"text": "󰒲", "tooltip": "hypridle: inactive", "class": "inactive"}'
        else
            # hypridle is not running, start it
            hypridle &
            sleep 0.5
            if pgrep -x hypridle > /dev/null 2>&1; then
                echo '{"text": "󰒳", "tooltip": "hypridle: active", "class": "active"}'
            else
                echo '{"text": "󰒲", "tooltip": "hypridle: failed to start", "class": "inactive"}'
            fi
        fi
        ;;
    "status")
        if pgrep -x hypridle > /dev/null 2>&1; then
            echo '{"text": "󰒳", "tooltip": "hypridle: active", "class": "active"}'
        else
            echo '{"text": "󰒲", "tooltip": "hypridle: inactive", "class": "inactive"}'
        fi
        ;;
esac