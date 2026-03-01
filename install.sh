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
    log "Installing $(wc -l < "$REPO_DIR/packages/pacman.txt") pacman packages..."
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        sudo pacman -S --noconfirm "$pkg" 2>/dev/null || warn "Failed: $pkg"
    done < "$REPO_DIR/packages/pacman.txt"
fi

# AUR packages
if [ -f "$REPO_DIR/packages/aur.txt" ]; then
    log "Installing $(wc -l < "$REPO_DIR/packages/aur.txt") AUR packages..."
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        yay -S --noconfirm "$pkg" 2>/dev/null || warn "Failed: $pkg"
    done < "$REPO_DIR/packages/aur.txt"
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

CONFIGS=(
    ".config/hyprland:$REPO_DIR/config/hyprland"
    ".config/waybar:$REPO_DIR/config/waybar"
    ".config/wofi:$REPO_DIR/config/wofi"
)

for item in "${CONFIGS[@]}"; do
    IFS=':' read -r src dest <<< "$item"
    if [ -d "$REPO_DIR/config/$src" ] || [ -f "$REPO_DIR/config/$src" ]; then
        rm -rf "$HOME/$src"
        ln -sf "$REPO_DIR/config/$src" "$HOME/$src"
        log "Linked $src"
    fi
done

# =============================================================================
# 6. ADDITIONAL SETUP
# =============================================================================
log "Additional setup..."

# Create useful dirs
mkdir -p ~/.local/share/icons

# Set permissions
chmod +x "$REPO_DIR"/scripts/*.sh 2>/dev/null || true

log "========================================="
log "Installation complete!"
log "========================================="
log "Review $LOG_FILE for any warnings"
log "Reboot recommended"
