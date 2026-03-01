#!/bin/bash

# Udev rule for backlight control - save this to apply later with sudo
cat << 'EOF' > /tmp/backlight-udev-rule.txt
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF

echo "Udev rule saved to /tmp/backlight-udev-rule.txt"
echo "Apply it later with:"
echo "sudo cp /tmp/backlight-udev-rule.txt /etc/udev/rules.d/99-backlight.rules"
echo "sudo udevadm trigger -c add -s backlight"