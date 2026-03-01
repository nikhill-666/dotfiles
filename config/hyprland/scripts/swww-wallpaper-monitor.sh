#!/bin/bash

# Script to monitor swww wallpaper changes and update hyprlock background
# Stores current wallpaper path for hyprlock to use

WALLPAPER_CACHE_DIR="$HOME/.config/hypr/cache"
WALLPAPER_FILE="$WALLPAPER_CACHE_DIR/current_wallpaper"

# Create cache directory if it doesn't exist
mkdir -p "$WALLPAPER_CACHE_DIR"

# Function to get current wallpaper from swww
get_current_wallpaper() {
    swww query | grep "image:" | sed 's/.*image: //' | xargs
}

# Function to update wallpaper file
update_wallpaper_file() {
    local current_wallpaper=$(get_current_wallpaper)
    if [ -n "$current_wallpaper" ] && [ -f "$current_wallpaper" ]; then
        echo "$current_wallpaper" > "$WALLPAPER_FILE"
        echo "Updated wallpaper cache: $current_wallpaper"
        
        # Update hyprlock.conf with the new wallpaper path
        sed -i "s|^    path = .*|    path = $current_wallpaper|" "$HOME/.config/hypr/hyprlock.conf"
        echo "Updated hyprlock.conf background path"
        
        # Sync wallpaper to SDDM (run with sudo if available)
        if command -v sudo >/dev/null 2>&1; then
            sudo -n "$HOME/arch/dotfiles/hypr/scripts/sync-sddm-wallpaper.sh" sync >/dev/null 2>&1 || echo "Skipping SDDM sync (sudo required)"
        fi
    fi
}

# Function to monitor swww changes
monitor_wallpaper_changes() {
    echo "Monitoring swww wallpaper changes..."
    
    # Initialize with current wallpaper
    update_wallpaper_file
    
    # Monitor swww socket for changes
    while true; do
        # Check if wallpaper changed by comparing with stored value
        current=$(get_current_wallpaper)
        stored=""
        if [ -f "$WALLPAPER_FILE" ]; then
            stored=$(cat "$WALLPAPER_FILE")
        fi
        
        if [ "$current" != "$stored" ]; then
            update_wallpaper_file
        fi
        
        sleep 2
    done
}

# Main execution
case "${1:-monitor}" in
    "update")
        update_wallpaper_file
        ;;
    "monitor")
        monitor_wallpaper_changes
        ;;
    "get")
        if [ -f "$WALLPAPER_FILE" ]; then
            cat "$WALLPAPER_FILE"
        else
            echo ""
        fi
        ;;
    *)
        echo "Usage: $0 [update|monitor|get]"
        echo "  update  - Update wallpaper cache with current swww wallpaper"
        echo "  monitor - Monitor for wallpaper changes (default)"
        echo "  get     - Get cached wallpaper path"
        exit 1
        ;;
esac