#!/bin/bash
# Robust dotfiles installer for CachyOS
# Run after: sudo pacman -Syu && reboot

# Don't exit on error - continue through warnings
set -uo pipefail

LOG_FILE="$HOME/dotfiles_install.log"
REPO_DIR="$HOME/dotfiles"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
info() { echo -e "${BLUE}[*]${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[X]${NC} $1" | tee -a "$LOG_FILE"; }

# Check running as user (not root)
if [ "$(id -u)" -eq 0 ]; then
    error "Run as user, not root!"
    exit 1
fi

cd "$HOME"

echo "========================================="
echo "  Dotfiles Installer"
echo "========================================="
log "Starting installation..."

# =============================================================================
# 0. VERIFY REPO
# =============================================================================
info "Verifying dotfiles repo..."
if [ ! -d "$REPO_DIR" ]; then
    error "Dotfiles repo not found at $REPO_DIR"
    exit 1
fi
if [ ! -d "$REPO_DIR/.git" ]; then
    error "Not a git repo: $REPO_DIR"
    exit 1
fi
log "Dotfiles repo verified: $REPO_DIR"

# =============================================================================
# 1. BASE DEPENDENCIES
# =============================================================================
log "=== STEP 1: Base Dependencies ==="

BASE_DEPS=(base-devel git curl wget rustup)

info "Updating system..."
sudo pacman -Syu --noconfirm || warn "System update had issues"

for pkg in "${BASE_DEPS[@]}"; do
    if pacman -Qq "$pkg" &>/dev/null; then
        info "  $pkg already installed"
    else
        info "  Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg" || warn "  Failed: $pkg"
    fi
done

# =============================================================================
# 2. INSTALL YAY
# =============================================================================
log "=== STEP 2: Install Yay ==="

if command -v yay &>/dev/null; then
    info "Yay already installed"
else
    info "Installing yay..."
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR" || { error "Failed to clone yay"; exit 1; }
    cd "$TEMP_DIR"
    makepkg -si --noconfirm || { error "Failed to build yay"; exit 1; }
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    log "Yay installed"
fi

# =============================================================================
# 3. INSTALL GH
# =============================================================================
log "=== STEP 3: Install GitHub CLI ==="

if command -v gh &>/dev/null; then
    info "gh already installed"
else
    info "Installing gh from AUR..."
    yay -S --noconfirm github-cli || warn "gh install failed"
fi

# =============================================================================
# 4. INSTALL PACKAGES
# =============================================================================
log "=== STEP 4: Install Packages ==="

# Pacman packages
if [ -f "$REPO_DIR/packages/pacman.txt" ]; then
    TOTAL=$(wc -l < "$REPO_DIR/packages/pacman.txt")
    info "Processing $TOTAL pacman packages..."
    COUNT=0
    SKIP=0
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        if pacman -Qq "$pkg" &>/dev/null; then
            ((SKIP++))
        else
            sudo pacman -S --noconfirm "$pkg" &>/dev/null && ((COUNT++)) || warn "Failed: $pkg"
        fi
    done < "$REPO_DIR/packages/pacman.txt"
    info "Pacman: Installed $COUNT, skipped $SKIP"
fi

# AUR packages
if [ -f "$REPO_DIR/packages/aur.txt" ]; then
    TOTAL=$(wc -l < "$REPO_DIR/packages/aur.txt")
    info "Processing $TOTAL AUR packages..."
    COUNT=0
    SKIP=0
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        if yay -Qq "$pkg" &>/dev/null; then
            ((SKIP++))
        else
            yay -S --noconfirm "$pkg" &>/dev/null && ((COUNT++)) || warn "Failed: $pkg"
        fi
    done < "$REPO_DIR/packages/aur.txt"
    info "AUR: Installed $COUNT, skipped $SKIP"
fi

# =============================================================================
# 5. CLONE REPOS
# =============================================================================
log "=== STEP 5: Clone Personal Repos ==="

# Check for SSH keys
info "Checking SSH keys..."
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    warn "No SSH key found at ~/.ssh/id_ed25519"
    info "Repos will need manual cloning or SSH key setup"
else
    info "SSH key found - adding to agent..."
    eval "$(ssh-agent -s)" 2>/dev/null
    ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null || warn "Failed to add SSH key"
    info "SSH key ready"
fi

REPOS=(
    "git@github.com:nikhill-666/obsidian.git:Documents/obsidian"
)

for repo in "${REPOS[@]}"; do
    IFS=':' read -r url dest <<< "$repo"
    if [ -d "$HOME/$dest" ]; then
        info "  $dest already exists, skipping"
    else
        info "  Cloning $url..."
        git clone "$url" "$HOME/$dest" 2>/dev/null || warn "Failed to clone $url"
    fi
done

# =============================================================================
# 6. LINK CONFIGS
# =============================================================================
log "=== STEP 6: Link Configs ==="

# Ensure .config exists
mkdir -p "$HOME/.config"

info "Checking config sources..."
info "  REPO_DIR: $REPO_DIR"
info "  Contents: $(ls $REPO_DIR/config/)"

CONFIGS=(
    "hypr:$REPO_DIR/config/hyprland"
    "waybar:$REPO_DIR/config/waybar"
    "wofi:$REPO_DIR/config/wofi"
    "aether:$REPO_DIR/config/aether"
    "ags:$REPO_DIR/config/ags"
    "mako:$REPO_DIR/config/mako"
    "walker:$REPO_DIR/config/walker"
    "alacritty:$REPO_DIR/config/alacritty"
    "kitty:$REPO_DIR/config/kitty"
    "fish:$REPO_DIR/config/fish"
    "rofi:$REPO_DIR/config/rofi"
)

for item in "${CONFIGS[@]}"; do
    IFS=':' read -r name dest <<< "$item"
    SRC_DIR="$HOME/.config/$name"
    
    info "Processing config: $name"
    info "  Source: $dest"
    info "  Exists: $([ -d "$dest" ] && echo yes || echo no)"
    
    if [ -d "$dest" ]; then
        rm -rf "$SRC_DIR"
        ln -sf "$dest" "$SRC_DIR"
        log "  Linked: $SRC_DIR -> $dest"
    else
        warn "  Source not found: $dest"
    fi
done

# Verify links
info "Verifying links..."
ls -la "$HOME/.config/" | grep -E "hyprland|waybar|wofi" || warn "No config links found!"

# =============================================================================
# 7. ADDITIONAL SETUP
# =============================================================================
log "=== STEP 7: Additional Setup ==="

# Create dirs
mkdir -p "$HOME/.local/share/icons"
mkdir -p "$HOME/.local/share/applications"

# Copy icons
if [ -f "$REPO_DIR/config/waybar/dumbbell.png" ]; then
    cp "$REPO_DIR/config/waybar/dumbbell.png" "$HOME/.local/share/icons/" 2>/dev/null && info "Copied dumbbell.png" || warn "Failed copy dumbbell.png"
    cp "$REPO_DIR/config/waybar/gym.png" "$HOME/.local/share/icons/" 2>/dev/null && info "Copied gym.png" || warn "Failed copy gym.png"
fi

# Create desktop entry
DESKTOP_FILE="$HOME/.local/share/applications/package-search.desktop"
if [ -f "$DESKTOP_FILE" ]; then
    info "Desktop entry exists"
else
    cat > "$DESKTOP_FILE" << 'EOF'
[Desktop Entry]
Name=Package Search
Comment=Search and install packages via Pacman/AUR
Exec=/home/nik/.config/waybar/scripts/package-search.sh
Icon=arch-linux
Type=Application
Categories=System;Utility;
Keywords=pacman;aur;package;install;yay;
EOF
    # Fix path
    sed -i "s|/home/nik/|$HOME/|g" "$DESKTOP_FILE"
    info "Created desktop entry"
fi

# Fix paths in configs
info "Fixing absolute paths in configs..."
find "$HOME/.config" -type f \( -name "*.sh" -o -name "*.conf" -o -name "*.jsonc" \) 2>/dev/null | while read f; do
    sed -i "s|/home/nik/|$HOME/|g" "$f" 2>/dev/null && info "  Fixed: $f" || true
done

# Set permissions
chmod +x "$REPO_DIR"/config/waybar/scripts/*.sh 2>/dev/null || true
chmod +x "$REPO_DIR"/config/hyprland/scripts/*.sh 2>/dev/null || true

log "========================================="
log "Installation complete!"
log "========================================="
log "Config links: ls -la ~/.config/"
log "Log file: $LOG_FILE"
log "REBOOT NOW!"
