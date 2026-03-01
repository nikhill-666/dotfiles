#!/bin/bash
echo "Starting script"
echo "Before kill"
pkill -f waybar || true
echo "After kill"
sleep 2
echo "Starting waybar simple"
waybar -c ~/.config/waybar/config-simple.jsonc -s ~/.config/waybar/style-simple.css &
echo "Script completed"