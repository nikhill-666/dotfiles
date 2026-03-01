#!/bin/bash
# ~/.config/waybar/scripts/run-cpu-widget.sh
# Loop forever, updating the CPU image
while true; do
    # Ensure correct environment/PATH for python and mpstat
    # If python is not in default PATH or mpstat is in a non-standard location, specify full paths.
    # e.g., /usr/bin/python3 /home/nik/.config/waybar/scripts/cpu_circle.py
    /usr/bin/python3 /home/nik/scripts/python/cpu.py > /dev/null 2>&1
    /usr/bin/python3 /home/nik/scripts/python/ram.py > /dev/null 2>&1
    sleep 1 # Wait 1 second before running again
done