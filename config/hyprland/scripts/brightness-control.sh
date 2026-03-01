#!/bin/bash

# Brightness control script using brightnessctl
# Uses brightnessctl for brightness control and notify-send for notifications

STEP=5  # 5% per keypress

# Calculate percentage
get_brightness_percentage() {
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl -m | cut -d',' -f4 | tr -d '%'
    else
        # Fallback to direct sysfs
        BACKLIGHT_DIR="/sys/class/backlight/intel_backlight"
        MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")
        CURRENT_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/brightness")
        echo $((CURRENT_BRIGHTNESS * 100 / MAX_BRIGHTNESS))
    fi
}

# Set brightness using brightnessctl or fallback
set_brightness() {
    local change=$1
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl set "$change"
    else
        # Fallback to direct sysfs with percentage calculation
        BACKLIGHT_DIR="/sys/class/backlight/intel_backlight"
        MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/max_brightness")
        CURRENT_BRIGHTNESS=$(cat "$BACKLIGHT_DIR/brightness")
        CURRENT_PERCENT=$((CURRENT_BRIGHTNESS * 100 / MAX_BRIGHTNESS))
        
        case "$change" in
            *%+)
                STEP=$(echo "$change" | sed 's/%+//')
                NEW_PERCENT=$((CURRENT_PERCENT + STEP))
                ;;
            *%-)
                STEP=$(echo "$change" | sed 's/%-//')
                NEW_PERCENT=$((CURRENT_PERCENT - STEP))
                ;;
            *%)
                NEW_PERCENT=$(echo "$change" | sed 's/%//')
                ;;
        esac
        
        # Clamp to valid range
        [[ $NEW_PERCENT -lt 1 ]] && NEW_PERCENT=1
        [[ $NEW_PERCENT -gt 100 ]] && NEW_PERCENT=100
        
        NEW_BRIGHTNESS=$((MAX_BRIGHTNESS * NEW_PERCENT / 100))
        echo "$NEW_BRIGHTNESS" > "$BACKLIGHT_DIR/brightness" 2>/dev/null
    fi
}

# Show notification
show_notification() {
    local percentage=$(get_brightness_percentage)
    
    # Determine icon based on brightness level
    if [[ $percentage -ge 75 ]]; then
        icon="display-brightness-high"
        message="☀️ $percentage%"
    elif [[ $percentage -ge 40 ]]; then
        icon="display-brightness-medium"
        message="🔆 $percentage%"
    elif [[ $percentage -ge 10 ]]; then
        icon="display-brightness-low"
        message="🔅 $percentage%"
    else
        icon="display-brightness-low"
        message="🌑 $percentage%"
    fi
    
    # Send notification (replace previous one with different ID)
    notify-send -a "Brightness Control" -u low -r 1002 -h string:x-canonical-private-synchronous:brightness "$message" "Brightness: $percentage%" -i "$icon"
}

# Main script logic
case "$1" in
    up)
        set_brightness "${STEP}%+"
        show_notification
        ;;
    down)
        set_brightness "${STEP}%-"
        show_notification
        ;;
    set)
        if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
            set_brightness "${2}%"
            show_notification
        else
            echo "Usage: $0 set <percentage>"
            exit 1
        fi
        ;;
    show)
        show_notification
        ;;
    *)
        echo "Usage: $0 {up|down|set <percentage>|show}"
        echo "Example: $0 set 50"
        exit 1
        ;;
esac