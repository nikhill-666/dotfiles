#!/bin/bash

# Waybar toggle script
if pgrep -x "waybar" >/dev/null 2>&1; then
    # Waybar is running, kill it
    pkill -x "waybar"
else
    # Waybar is not running, start it
    waybar &
fi