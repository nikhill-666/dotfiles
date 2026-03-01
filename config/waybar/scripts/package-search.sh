#!/bin/bash
# Wofi-based package search and install for Pacman/AUR

# Choose package manager
CHOICE=$(echo -e "pacman\nyay (AUR)" | wofi --dmenu --prompt="Search packages:" --height=200)

case "$CHOICE" in
    "pacman")
        SEARCH_CMD="pacman -Ss"
        ;;
    "yay (AUR)")
        SEARCH_CMD="yay -Ss"
        ;;
    *)
        exit 0
        ;;
esac

# Get search query
QUERY=$(wofi --dmenu --prompt="Search $CHOICE:")

if [ -z "$QUERY" ]; then
    exit 0
fi

# Get package list
PACKAGES=$($SEARCH_CMD "$QUERY" 2>/dev/null)

# Format for wofi: name - description (handle multi-line format)
FORMATTED=$(echo "$PACKAGES" | awk '
    /^[^ ]/ {
        split($1, a, "/");
        name = a[2] ? a[2] : a[1];
        desc = "";
    }
    /^    / {
        desc = substr($0, 5);
        if (length(desc) > 50) desc = substr(desc, 1, 47) "...";
        printf "%-35s %s\n", name, desc
    }
' | wofi --dmenu --prompt="Install:" --height=400)

if [ -z "$FORMATTED" ]; then
    exit 0
fi

# Extract package name
PKG_NAME=$(echo "$FORMATTED" | awk '{print $1}')

# Confirm install
CONFIRM=$(echo -e "Yes\nNo" | wofi --dmenu --prompt="Install $PKG_NAME?" --height=100)

if [ "$CONFIRM" = "Yes" ]; then
    # Notify start
    notify-send -u critical "Installing $PKG_NAME..." "Starting installation..."
    
    # Run in terminal for sudo prompt + progress
    if [ "$CHOICE" = "pacman" ]; then
        ghostty -e sudo pacman -S --noconfirm "$PKG_NAME"
    else
        ghostty -e yay -S --noconfirm "$PKG_NAME"
    fi
    
    # Notify completion (after terminal closes)
    notify-send "Installation Complete" "$PKG_NAME"
fi
