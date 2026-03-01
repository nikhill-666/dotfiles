#!/bin/bash

# Check if any chromium window was initialized as an Incognito tab
CHECK=$(hyprctl clients -j | jq -r '.[] | select(.class=="chromium" and .initialTitle=="New Incognito Tab - Chromium")')

if [ ! -z "$CHECK" ]; then
    echo '{"text": "PRIV", "tooltip": "Chromium Private Session Active", "class": "private"}'
else
    echo '{"text": "", "tooltip": "", "class": "none"}'
fi
