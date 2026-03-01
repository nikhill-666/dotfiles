#!/bin/bash

# Define homelab servers
declare -A servers=(
    ["192.168.1.138"]="solaris.lan"
    ["192.168.1.140"]="media.lan"
    ["192.168.1.141"]="arrstack.lan"
    ["192.168.1.145"]="artemis.lan"
    ["192.168.1.210"]="luna.lan"
)

# Define NAS servers
declare -A nas_servers=(
    ["192.168.1.105"]="Synology NAS"
    ["192.168.1.205"]="QNAP NAS"
)

# Check server status and build tooltip
tooltip="Homelab Server Status:\n"
up_count=0
total_count=$((${#servers[@]} + ${#nas_servers[@]}))

# Check homelab servers
for ip in "${!servers[@]}"; do
    name="${servers[$ip]}"
    if ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
        status="🟢 UP"
        ((up_count++))
    else
        status="🔴 DOWN"
    fi
    tooltip+="  $status $name ($ip)\n"
done

# Add divider
tooltip+="\n─────────────────\nNAS Storage Status:\n"

# Check NAS servers
for ip in "${!nas_servers[@]}"; do
    name="${nas_servers[$ip]}"
    if ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
        status="🟢 UP"
        ((up_count++))
    else
        status="🔴 DOWN"
    fi
    tooltip+="  $status $name ($ip)\n"
done

# Determine overall VPN status and appearance
if [ $up_count -eq $total_count ]; then
    text="HOME"
    class="vpn-up"
    status_msg="All servers online"
elif [ $up_count -gt 0 ]; then
    text="PARTIAL"
    class="vpn-partial"
    status_msg="$up_count/$total_count servers online"
else
    text="OFFLINE"
    class="vpn-down"
    status_msg="All servers offline"
fi

# Add summary to tooltip
tooltip+="\n$status_msg"

# Output JSON for Waybar
echo "{\"text\": \"$text\", \"class\": \"$class\", \"tooltip\": \"$tooltip\"}"
