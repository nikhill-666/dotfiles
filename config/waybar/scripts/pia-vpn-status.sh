#!/bin/bash

# PIA VPN Status for Waybar

state=$(piactl get connectionstate 2>/dev/null)
region=$(piactl get region 2>/dev/null)

case "$state" in
    "Connected")
        text="VPN $region"
        class="vpn-connected"
        tooltip="PIA VPN Connected\nRegion: $region"
        ;;
    "Connecting")
        text="VPN ..."
        class="vpn-connecting"
        tooltip="PIA VPN Connecting..."
        ;;
    "Disconnected")
        text="VPN Off"
        class="vpn-disconnected"
        tooltip="PIA VPN Disconnected\nRegion: $region"
        ;;
    *)
        text="VPN ?"
        class="vpn-unknown"
        tooltip="VPN Status Unknown: $state"
        ;;
esac

echo "{\"text\": \"$text\", \"class\": \"$class\", \"tooltip\": \"$tooltip\"}"
