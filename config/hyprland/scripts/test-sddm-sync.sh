#!/bin/bash

# Test version of SDDM sync script that works without sudo
# This shows what would happen when run with proper permissions

WALLPAPER_CACHE_DIR="$HOME/.config/hypr/cache"
WALLPAPER_FILE="$WALLPAPER_CACHE_DIR/current_wallpaper"
SDDM_THEME_DIR="/usr/share/sddm/themes/silent"

# Function to get current wallpaper from swww
get_current_wallpaper() {
    swww query | grep "image:" | sed 's/.*image: //' | xargs
}

# Test function to show what would be copied
test_sync_wallpaper() {
    echo "Testing SDDM wallpaper sync..."
    
    # Get current wallpaper
    local current_wallpaper=$(get_current_wallpaper)
    
    if [ -z "$current_wallpaper" ]; then
        echo "Error: No current wallpaper found"
        return 1
    fi
    
    echo "Current wallpaper: $current_wallpaper"
    
    # Get wallpaper filename
    local wallpaper_name=$(basename "$current_wallpaper")
    local sddm_wallpaper_path="$SDDM_THEME_DIR/backgrounds/$wallpaper_name"
    
    echo "Would copy: $current_wallpaper -> $sddm_wallpaper_path"
    echo "Would update SDDM config to use: $wallpaper_name"
    
    # Store the wallpaper name for reference
    mkdir -p "$WALLPAPER_CACHE_DIR"
    echo "$wallpaper_name" > "$WALLPAPER_CACHE_DIR/sddm_wallpaper_name"
    echo "Test completed. Run with sudo to apply changes."
    
    return 0
}

test_sync_wallpaper