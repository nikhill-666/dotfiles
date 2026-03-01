#!/bin/bash
CACHE_FILE="$HOME/.cache/waybar_weather.json"

if [ -f "$CACHE_FILE" ]; then
    # Extract the 'text' field which already has "Temp, Conditions"
    weather_text=$(jq -r '.text' "$CACHE_FILE" | sed 's/\. $//')
    
    # Optional: If you want to keep it minimal for a lockscreen
    echo "$weather_text"
else
    echo "Weather Unavailable"
fi
