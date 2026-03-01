# Waybar Config Switcher

## Usage

### Command Line
```bash
# Switch to simple/chill config
~/.config/waybar/scripts/waybar-switch.sh simple

# Switch to full/standard config  
~/.config/waybar/scripts/waybar-switch.sh standard

# Toggle between configs
~/.config/waybar/scripts/waybar-switch.sh toggle

# Check current mode
~/.config/waybar/scripts/waybar-switch.sh
```

### Hyprland Keybinding
Add this to your Hyprland config to toggle with Super+W:
```
bind = $mainMod, W, exec, ~/.config/waybar/scripts/waybar-toggle.sh
```

## Configs Available

- **Standard** (`config.jsonc` + `style.css`): Full feature set with all modules
- **Simple/Chill** (`config-simple.jsonc` + `style-simple.css`): Minimal config with just workspaces, clock, weather, battery, and hypridle

The script automatically restarts Waybar when switching configs.