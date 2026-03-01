#!/bin/bash

# Volume notification script for Hyprland
# Uses pactl for volume control and notify-send for notifications

# Get current volume and mute status
get_volume_info() {
    local volume_info=$(pactl get-sink-volume @DEFAULT_SINK@)
    local mute_status=$(pactl get-sink-mute @DEFAULT_SINK@)
    
    # Extract volume percentage (front-left channel)
    local volume=$(echo "$volume_info" | grep -o '[0-9]\+%' | head -1 | sed 's/%//')
    
    # Check if muted
    if [[ "$mute_status" == *"Mute: yes"* ]]; then
        echo "muted:$volume"
    else
        echo "unmuted:$volume"
    fi
}

# Show notification
show_notification() {
    local status_info=$(get_volume_info)
    local status=$(echo "$status_info" | cut -d: -f1)
    local volume=$(echo "$status_info" | cut -d: -f2)
    
    # Determine icon and message
    if [[ "$status" == "muted" ]]; then
        icon="audio-volume-muted"
        message="🔇 Muted"
    else
        if [[ $volume -ge 66 ]]; then
            icon="audio-volume-high"
        elif [[ $volume -ge 33 ]]; then
            icon="audio-volume-medium"
        else
            icon="audio-volume-low"
        fi
        message="🔊 $volume%"
    fi
    
    # Send notification (replace previous one)
    notify-send -a "Volume Control" -u low -r 1001 -h string:x-canonical-private-synchronous:volume "$message" "Volume: $volume%" -i "$icon"
}

# Main script logic
case "$1" in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        show_notification
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        show_notification
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        show_notification
        ;;
    show)
        show_notification
        ;;
    *)
        echo "Usage: $0 {up|down|mute|show}"
        exit 1
        ;;
esac