# Dotfiles

My CachyOS rice. For Omarchy setup, see [arch repo](https://github.com/nikhill-666/arch).

> **Note:** The `scripts/` folder is shared across both platforms (platform agnostic). This repo is for CachyOS-specific configs.

## Structure

```
dotfiles/           # CachyOS setup
├── config/          # Hyprland, waybar, wofi configs
├── packages/        # pacman.txt, aur.txt
└── install.sh      # Bootstrapper
```

## Usage

On fresh CachyOS:

```bash
# 1. Update system
sudo pacman -Syu && reboot

# 2. Clone this repo
git clone git@github.com:nikhill-666/dotfiles.git ~/dotfiles

# 3. Run installer
cd ~/dotfiles && ./install.sh
```

## What's Installed

- **Hyprland** + waybar + wofi
- **Aether** theming (shaders, mpvpaper)
- **SDDM** theming
- **All apps** from package lists
- **Personal repos** (obsidian, etc.)

## Manual Steps After Install

1. **SSH keys** — add to ssh-agent if needed
2. **GHA/2FA** — re-auth any CLI tools
3. **NAS credentials** — `~/.creds` file
4. **PIA VPN** — configure or restore config
5. **SDDM** — theming applied automatically
6. **Hyprland** — startx or wayland session

## Notes

- AUR packages build from PKGBUILDs (may take time)
- Logs written to `~/dotfiles_install.log`
- Some configs symlinked — edit in `~/dotfiles` and push
