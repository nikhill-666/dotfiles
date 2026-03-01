#!/bin/bash
BATTERY_INFO=$(acpi -b)
if echo "$BATTERY_INFO" | grep -q " Full"; then
    echo "󰁹 100%"
elif echo "$BATTERY_INFO" | grep -q " Charging"; then
    PERCENT=$(echo "$BATTERY_INFO" | cut -d, -f2 | tr -d ' %')
    TIME=$(echo "$BATTERY_INFO" | cut -d, -f3 | awk '{print $1}' | cut -d: -f1,2)
    echo "󰂄 $PERCENT%   $TIME remaining"
elif echo "$BATTERY_INFO" | grep -q " Discharging"; then
    PERCENT=$(echo "$BATTERY_INFO" | cut -d, -f2 | tr -d ' %')
    TIME=$(echo "$BATTERY_INFO" | cut -d, -f3 | awk '{print $1}' | cut -d: -f1,2)
    echo "󰂃 $PERCENT%   $TIME remaining"
else
    echo "󰂞 Unknown"
fi
