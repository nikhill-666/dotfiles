#!/bin/bash
# Robust dotfiles installer for CachyOS
# Run after: sudo pacman -Syu && reboot

set -euo pipefail

LOG_FILE="$HOME/dotfiles_install.log"
REPO_DIR="$HOME/dotfiles"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[X]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }

# Check running as user (not root)
[ "$(id -u)" -eq 0 ] && error "Run as user, not root!"

cd "$HOME"

log "Starting dotfiles installation..."

# =============================================================================
# 1. BASE DEPENDENCIES
# =============================================================================
log "Installing base build dependencies..."

BASE_DEPS=(
    base-devel git curl wget rustup
)

if ! sudo pacman -Syu --noconfirm; then
    error "Failed to update system"
fi

for pkg in "${BASE_DEPS[@]}"; do
    pacman -Qq "$pkg" &>/dev/null || sudo pacman -S --noconfirm "$pkg" || warn "$pkg failed to install"
done

# =============================================================================
# 2. INSTALL YAY (required for AUR packages like gh)
# =============================================================================
if ! command -v yay &>/dev/null; then
    log "Installing yay..."
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR" 2>/dev/null || error "Failed to clone yay"
    cd "$TEMP_DIR"
    makepkg -si --noconfirm 2>/dev/null || error "Failed to build yay"
    cd "$HOME"
    rm -rf "$TEMP_DIR"
else
    log "yay already installed"
fi

# =============================================================================
# 3. INSTALL GH (from AUR)
# =============================================================================
if ! command -v gh &>/dev/null; then
    log "Installing gh from AUR..."
    yay -S --noconfirm github-cli 2>/dev/null || warn "gh failed to install"
else
    log "gh already installed"
fi

# =============================================================================
# 3. INSTALL PACKAGES
# =============================================================================
log "Installing packages from lists..."

# Pacman packages
if [ -f "$REPO_DIR/packages/pacman.txt" ]; then
    TOTAL=$(wc -l < "$REPO_DIR/packages/pacman.txt")
    log "Installing $TOTAL pacman packages (skipping already installed)..."
    COUNT=0
    SKIP=0
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        if pacman -Qq "$pkg" &>/dev/null; then
            ((SKIP++))
            continue
        fi
        sudo pacman -S --noconfirm "$pkg" 2>/dev/null && ((COUNT++)) || warn "Failed: $pkg"
    done < "$REPO_DIR/packages/pacman.txt"
    log "Installed $COUNT new packages, skipped $SKIP already installed"
fi

# AUR packages
if [ -f "$REPO_DIR/packages/aur.txt" ]; then
    TOTAL=$(wc -l < "$REPO_DIR/packages/aur.txt")
    log "Installing $TOTAL AUR packages (skipping already installed)..."
    COUNT=0
    SKIP=0
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        if yay -Qq "$pkg" &>/dev/null; then
            ((SKIP++))
            continue
        fi
        yay -S --noconfirm "$pkg" 2>/dev/null && ((COUNT++)) || warn "Failed: $pkg"
    done < "$REPO_DIR/packages/aur.txt"
    log "Installed $COUNT new AUR packages, skipped $SKIP already installed"
fi

# =============================================================================
# 4. CLONE REPOS
# =============================================================================
log "Cloning personal repos..."

REPOS=(
    "git@github.com:nikhill-666/obsidian.git:Documents/obsidian"
    # Note: arch repo is Omarchy-based, not CachyOS - add separately if needed
)

for repo in "${REPOS[@]}"; do
    IFS=':' read -r url dest <<< "$repo"
    if [ ! -d "$HOME/$dest" ]; then
        log "Cloning $url..."
        git clone "$url" "$HOME/$dest" 2>/dev/null || warn "Failed to clone $url"
    else
        warn "$dest already exists, skipping"
    fi
done

# =============================================================================
# 5. SYMLINK CONFIGS
# =============================================================================
log "Linking configs..."

# Ensure .config exists
mkdir -p "$HOME/.config"

# Link main configs
CONFIGS=(
    "hyprland:$REPO_DIR/config/hyprland"
    "waybar:$REPO_DIR/config/waybar"
    "wofi:$REPO_DIR/config/wofi"
)

for item in "${CONFIGS[@]}"; do
    IFS=':' read -r name dest <<< "$item"
    SRC_DIR="$HOME/.config/$name"
    if [ -d "$dest" ]; then
        rm -rf "$SRC_DIR"
        ln -sf "$dest" "$SRC_DIR"
        log "Linked ~/.config/$name"
    else
        warn "Source $dest not found"
    fi
done

# =============================================================================
# 6. ADDITIONAL SETUP
# =============================================================================
log "Additional setup..."

# Create useful dirs
mkdir -p ~/.local/share/icons ~/.local/share/applications

# Copy desktop entry for package-search
if [ -f "$HOME/.local/share/applications/package-search.desktop" ]; then
    log "Desktop entry already exists"
else
    mkdir -p ~/.local/share/applications
    cat > ~/.local/share/applications/package-search.desktop << 'EOF'
[Desktop Entry]
Name=Package Search
Comment=Search and install packages via Pacman/AUR
Exec=/home/nik/.config/waybar/scripts/package-search.sh
Icon=arch-linux
Type=Application
Categories=System;Utility;
Keywords=pacman;aur;package;install;yay;
EOF
    # Fix path for new machine
    sed -i "s|/home/nik/|$HOME/|g" ~/.local/share/applications/package-search.desktop
    log "Created desktop entry"
fi

# Copy icons
if [ -f "$REPO_DIR/config/waybar/dumbbell.png" ]; then
    cp "$REPO_DIR/config/waybar/dumbbell.png" ~/.local/share/icons/ 2>/dev/null
    cp "$REPO_DIR/config/waybar/gym.png" ~/.local/share/icons/ 2>/dev/null
fi

# Fix absolute paths in configs (replace /home/nik with $HOME)
log "Fixing absolute paths in configs..."
find "$HOME/.config" -type f \( -name "*.sh" -o -name "*.conf" -o -name "*.jsonc" \) -exec sed -i "s|/home/nik/|$HOME/|g" {} \; 2>/dev/null

log "Config setup complete!"

# Set permissions
chmod +x "$REPO_DIR"/scripts/*.sh 2>/dev/null || true

log "========================================="
log "Installation complete!"
log "========================================="
log "Review $LOG_FILE for any warnings"
log "Reboot recommended"
