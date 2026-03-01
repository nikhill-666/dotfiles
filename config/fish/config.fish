# opencode
fish_add_path /home/nik/.opencode/bin

# WireGuard aliases
alias homelab-up "sudo wg-quick up cachyos"
alias homelab-down "sudo wg-quick down cachyos"

source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end




alias aether="aether-fixed"

# OpenClaw Completion
source "/home/nik/.openclaw/completions/openclaw.fish"
