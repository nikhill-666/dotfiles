#!/bin/bash

# Simple mpvpaper toggle script
# Starts or kills mpvpaper animated wallpaper

# Configuration
VIDEO_FILES=(
    "/usr/share/sddm/themes/silent/backgrounds/rei.mp4"
    "/usr/share/sddm/themes/silent/backgrounds/ken.mp4" 
    "/usr/share/sddm/themes/silent/backgrounds/silvia.mp4"
    "/home/nik/Downloads/tech-hud.1920x1080.mp4"
)
DEFAULT_VIDEO="${VIDEO_FILES[0]}"
OUTPUT="eDP-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if mpvpaper is running
is_mpvpaper_running() {
    pgrep -x "mpvpaper" > /dev/null
}

# Function to start mpvpaper
start_mpvpaper() {
    local video_file="$1"
    
    # Kill any existing mpvpaper first
    pkill -x mpvpaper
    sleep 1
    
    echo -e "${GREEN}Starting mpvpaper with $(basename "$video_file")${NC}"
    
    # Start mpvpaper with hardware acceleration and loop
    mpvpaper -f -o "no-audio loop hwdec=auto" "$OUTPUT" "$video_file" &
    
    # Wait a moment and check if it started successfully
    sleep 2
    if is_mpvpaper_running; then
        echo -e "${GREEN}✓ mpvpaper started successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to start mpvpaper${NC}"
        return 1
    fi
}

# Function to select video interactively (terminal only)
select_video() {
    if [ ! -t 0 ]; then
        echo -e "${RED}Video selection only available in terminal mode${NC}"
        echo -e "${YELLOW}Use: ./mpvpaper-toggle.sh select${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Available video files:${NC}"
    for i in "${!VIDEO_FILES[@]}"; do
        local video="${VIDEO_FILES[$i]}"
        if [ -f "$video" ]; then
            local size=$(du -h "$video" | cut -f1)
            echo -e "  ${GREEN}$((i+1)).${NC} $(basename "$video") (${size})"
        else
            echo -e "  ${RED}$((i+1)).${NC} $(basename "$video") (${RED}not found${NC})"
        fi
    done
    
    echo -e "${YELLOW}Select a video (1-${#VIDEO_FILES[@]}): ${NC}"
    read -r selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#VIDEO_FILES[@]}" ]; then
        local selected_video="${VIDEO_FILES[$((selection-1))]}"
        if [ -f "$selected_video" ]; then
            echo -e "${GREEN}Selected: $(basename "$selected_video")${NC}"
            echo "$selected_video"
        else
            echo -e "${RED}Error: Selected file not found${NC}"
            return 1
        fi
    else
        echo -e "${RED}Invalid selection${NC}"
        return 1
    fi
}

# Function to stop mpvpaper
stop_mpvpaper() {
    if ! is_mpvpaper_running; then
        echo -e "${YELLOW}mpvpaper is not running${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Stopping mpvpaper...${NC}"
    pkill mpvpaper
    
    # Wait and confirm it stopped
    sleep 1
    if ! is_mpvpaper_running; then
        echo -e "${GREEN}✓ mpvpaper stopped successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to stop mpvpaper${NC}"
        return 1
    fi
}

# Function to show status
show_status() {
    if is_mpvpaper_running; then
        echo -e "${GREEN}mpvpaper is running${NC}"
# Show which video is playing
        local pid=$(pgrep -x "mpvpaper")
        if [ -n "$pid" ]; then
            echo -e "${GREEN}Process ID: $pid${NC}"
        fi
    else
        echo -e "${YELLOW}mpvpaper is not running${NC}"
    fi
}

# Function to list available videos
list_videos() {
    echo -e "${GREEN}Available video files:${NC}"
    for i in "${!VIDEO_FILES[@]}"; do
        local video="${VIDEO_FILES[$i]}"
        if [ -f "$video" ]; then
            local size=$(du -h "$video" | cut -f1)
            echo -e "  ${GREEN}$((i+1)).${NC} $(basename "$video") (${size})"
        else
            echo -e "  ${RED}$((i+1)).${NC} $(basename "$video") (${RED}not found${NC})"
        fi
    done
}

# Main script logic
case "${1:-toggle}" in
    "start"|"stop"|"toggle")
        # For keybind usage - just toggle with default video
        if [ "$1" = "toggle" ]; then
            if is_mpvpaper_running; then
                stop_mpvpaper
            else
                start_mpvpaper "$DEFAULT_VIDEO"
            fi
        elif [ "$1" = "start" ]; then
            start_mpvpaper "$DEFAULT_VIDEO"
        elif [ "$1" = "stop" ]; then
            stop_mpvpaper
        fi
        ;;
    "status")
        show_status
        ;;
    "list")
        list_videos
        ;;
    "select")
        selected_video=$(select_video)
        if [ $? -eq 0 ] && [ -n "$selected_video" ]; then
            if is_mpvpaper_running; then
                stop_mpvpaper
                sleep 1
            fi
            start_mpvpaper "$selected_video"
        fi
        ;;
    "restart")
        stop_mpvpaper
        sleep 1
        start_mpvpaper "$DEFAULT_VIDEO"
        ;;
    *)
        echo "Usage: $0 [start|stop|toggle|status|list|select|restart]"
        echo "  start   - Start mpvpaper with default video"
        echo "  stop    - Stop mpvpaper"
        echo "  toggle  - Toggle mpvpaper on/off (default)"
        echo "  status  - Show current status"
        echo "  list    - List available video files"
        echo "  select  - Select and start a video (terminal only)"
        echo "  restart - Restart mpvpaper"
        exit 1
        ;;
esac