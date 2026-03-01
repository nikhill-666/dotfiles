#!/bin/bash

# --- Configuration ---
REMOTE_USER="nik"
REMOTE_HOST="192.168.1.138"
CHECK_TIME=$(date +"%H:%M:%S")

# Calculate the timestamp for 60 minutes ago
# Format: 2026-01-04 07:24 (Matches the start of your fail2ban log lines)
WINDOW_START=$(date -d "60 minutes ago" +"%Y-%m-%d %H:%M:%S")

# --- Thresholds ---
WARN_BAN_LIMIT=5      
CRIT_ATTEMPT_LIMIT=150 
CRIT_BAN_LIMIT=10     

# --- Data Acquisition ---
# We pass the WINDOW_START variable to awk on the remote server.
# Awk compares the date/time ($1" "$2) of each line against our rolling start point.
STATS=$(ssh -o ConnectTimeout=3 $REMOTE_USER@$REMOTE_HOST \
    "awk -v start=\"$WINDOW_START\" '\$1\" \"\$2 >= start {print \$6, \$7}' /var/log/fail2ban.log" 2>/dev/null)

# Exit gracefully if Solaris is unreachable
if [[ $? -ne 0 ]]; then
    echo "{\"text\": \"󰣼\", \"tooltip\": \"󱄊 Solaris Offline\nLast Attempt: $CHECK_TIME\", \"class\": \"offline\"}"
    exit 0
fi

# Parse counts from the returned stats
# Note: $6 and $7 in the log are usually 'fail2ban.filter [551]: INFO [sshd] Found'
# So we check if the collected lines contain 'Found' or 'Ban'
ATTEMPTS=$(echo "$STATS" | grep -c "Found")
BANS=$(echo "$STATS" | grep -c "Ban")

# --- Visual Logic ---
ICON_A="󱚟" 
ICON_B="󰒃" 
CLASS="safe"

if [[ $BANS -ge $CRIT_BAN_LIMIT ]] || [[ $ATTEMPTS -ge $CRIT_ATTEMPT_LIMIT ]]; then
    CLASS="critical"
elif [[ $BANS -ge $WARN_BAN_LIMIT ]]; then
    CLASS="warning"
fi

# --- JSON Output ---
echo "{\"text\": \"$ICON_A $ATTEMPTS  <span color='#585b70'>|</span>  $ICON_B $BANS\", \"tooltip\": \"Rolling 60 Minute Window\n󱚟 Attempts: $ATTEMPTS\n󰒃 Total Bans: $BANS\n\n󱎫 Last Checked: $CHECK_TIME\", \"class\": \"$CLASS\"}"
