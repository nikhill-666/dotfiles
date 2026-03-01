#!/bin/bash

# Directory containing your wallpapers
WALLPAPER_DIR="/home/nik/Wallpapers"

# Select a random file using find and shuf
# This handles spaces in filenames better than a simple ls
PICS=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \))
RANDOM_PIC=$(echo "$PICS" | shuf -n 1)
echo "$RANDOM_PIC choosen."
# Execute swww with the 'center expand' transition
swww img "$RANDOM_PIC" \
    --transition-type grow \
    --transition-pos center \
    --transition-duration 2 \
    --transition-fps 60 \
    --transition-bezier .42,0,.58,1
