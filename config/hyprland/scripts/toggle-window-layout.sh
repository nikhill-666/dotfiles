#!/bin/bash

# Toggle window between tiled and floating (50% width/height, centered)
# Applies to the currently focused window

# Get active window information
WINDOW_INFO=$(hyprctl activewindow -j)
WINDOW_CLASS=$(echo "$WINDOW_INFO" | jq -r '.class')
WINDOW_ADDRESS=$(echo "$WINDOW_INFO" | jq -r '.address')
IS_FLOATING=$(echo "$WINDOW_INFO" | jq -r '.floating')

# Get monitor dimensions for calculations
MONITOR_INFO=$(hyprctl monitors -j | jq '.[] | select(.focused == true)')
MONITOR_WIDTH=$(echo "$MONITOR_INFO" | jq -r '.width')
MONITOR_HEIGHT=$(echo "$MONITOR_INFO" | jq -r '.height')

# Calculate target dimensions (50% of monitor size)
TARGET_WIDTH=$((MONITOR_WIDTH / 2))
TARGET_HEIGHT=$((MONITOR_HEIGHT / 2))

# Calculate position to center the window
X_POS=$(((MONITOR_WIDTH - TARGET_WIDTH) / 2))
Y_POS=$(((MONITOR_HEIGHT - TARGET_HEIGHT) / 2))

# Function to make window floating with specified dimensions
make_floating() {
    # First make the current window floating (no address needed)
    hyprctl dispatch setfloating
    sleep 0.1
    
    # Then use address for move and resize operations
    hyprctl dispatch movewindowpixel exact $X_POS $Y_POS,address:$WINDOW_ADDRESS
    sleep 0.1
    hyprctl dispatch resizewindowpixel exact $TARGET_WIDTH $TARGET_HEIGHT,address:$WINDOW_ADDRESS
}

# Function to make window tiled
make_tiled() {
    hyprctl dispatch settiled
}

# Toggle logic
if [ "$IS_FLOATING" = "false" ]; then
    # Window is tiled, make it floating
    make_floating
else
    # Window is floating, make it tiled
    make_tiled
fi