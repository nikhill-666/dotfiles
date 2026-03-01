#!/bin/bash
echo "Starting script"
echo "Killing waybar"
pkill -f waybar 2>/dev/null || echo "No waybar processes found"
echo "Sleeping"
sleep 2
echo "Starting waybar simple"
waybar -c ~/.config/waybar/config-simple.jsonc -s ~/.config/waybar/style-simple.css &
echo "Script completed"