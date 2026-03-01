#!/bin/bash

# Path to Pywal cache
PYWAL_CACHE="$HOME/.cache/wal/colors.json"

if [ -f "$PYWAL_CACHE" ]; then
    # Read colors from Pywal cache
    COLOR0=$(jq -r '.colors.color0' "$PYWAL_CACHE")
    COLOR1=$(jq -r '.colors.color1' "$PYWAL_CACHE")
    COLOR2=$(jq -r '.colors.color2' "$PYWAL_CACHE")
    COLOR3=$(jq -r '.colors.color3' "$PYWAL_CACHE")
    COLOR4=$(jq -r '.colors.color4' "$PYWAL_CACHE")
    COLOR5=$(jq -r '.colors.color5' "$PYWAL_CACHE")
    COLOR6=$(jq -r '.colors.color6' "$PYWAL_CACHE")
    COLOR7=$(jq -r '.colors.color7' "$PYWAL_CACHE")
    COLOR8=$(jq -r '.colors.color8' "$PYWAL_CACHE")
    COLOR9=$(jq -r '.colors.color9' "$PYWAL_CACHE")
    COLOR10=$(jq -r '.colors.color10' "$PYWAL_CACHE")
    COLOR11=$(jq -r '.colors.color11' "$PYWAL_CACHE")
    COLOR12=$(jq -r '.colors.color12' "$PYWAL_CACHE")
    COLOR13=$(jq -r '.colors.color13' "$PYWAL_CACHE")
    COLOR14=$(jq -r '.colors.color14' "$PYWAL_CACHE")
    COLOR15=$(jq -r '.colors.color15' "$PYWAL_CACHE")
    BACKGROUND=$(jq -r '.special.background' "$PYWAL_CACHE")
    FOREGROUND=$(jq -r '.special.foreground' "$PYWAL_CACHE")

    # Output colors in JSON format for Waybar
    echo '{'
    echo '  "background": "'"$BACKGROUND"'",'
    echo '  "foreground": "'"$FOREGROUND"'",'
    echo '  "color0": "'"$COLOR0"'",'
    echo '  "color1": "'"$COLOR1"'",'
    echo '  "color2": "'"$COLOR2"'",'
    echo '  "color3": "'"$COLOR3"'",'
    echo '  "color4": "'"$COLOR4"'",'
    echo '  "color5": "'"$COLOR5"'",'
    echo '  "color6": "'"$COLOR6"'",'
    echo '  "color7": "'"$COLOR7"'",'
    echo '  "color8": "'"$COLOR8"'",'
    echo '  "color9": "'"$COLOR9"'",'
    echo '  "color10": "'"$COLOR10"'",'
    echo '  "color11": "'"$COLOR11"'",'
    echo '  "color12": "'"$COLOR12"'",'
    echo '  "color13": "'"$COLOR13"'",'
    echo '  "color14": "'"$COLOR14"'",'
    echo '  "color15": "'"$COLOR15"'"'
    echo '}'
else
    # Pywal cache not found, use default colors
    echo '{"background": "#282828", "foreground": "#ebdbb2"}'
fi
