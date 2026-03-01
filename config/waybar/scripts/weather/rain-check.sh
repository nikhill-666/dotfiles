#!/bin/bash

#source "$HOME/scripts/piper-tts-library.sh"
WEATHER_DATA=$(/home/nik/.config/waybar/scripts/weather/weatherv2.sh)

RAIN_PRESENT=$(echo "$WEATHER_DATA" | grep -o "No rain is due.")

if [[ "$RAIN_PRESENT" == "No rain is due." ]]; then
    echo '{"text": "", "class": "dry-text"}'
else
    echo '{"text": "RAIN", "class": "rain-text"}'
    #speak_message "Rain is in the area. Please check weather."
    hyprctl notify 2 6000 2 RAIN is in the Area!
fi
