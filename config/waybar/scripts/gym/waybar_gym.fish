#!/usr/bin/env fish

set gym_data_remote "$HOME/gym/gym_data.json"
set gym_data_local "$HOME/scripts/gym/gym_data.json"

# Use remote data if available, otherwise local
if test -f "$gym_data_remote"
    set gym_data "$gym_data_remote"
else
    set gym_data "$gym_data_local"
end

# Get current day of week
set day_of_week (date +%a)

# Check if it's a gym day
set routine (jq -r ".routines.$day_of_week[1]" $gym_data 2>/dev/null)

if test "$routine" = "Rest" -o -z "$routine" -o "$routine" = "null"
    echo '{"text": "", "tooltip": "Rest day", "class": "rest-day"}'
    exit 0
end

# Get today's routine
set exercises (jq -r ".routines.$day_of_week | .[]" $gym_data)

# Build tooltip content
set tooltip "Today's routine ($day_of_week):\\n"

for exercise in $exercises
    # Find latest entry for this exercise
    set last_entry (jq -r --arg ex "$exercise" '.history | map(select(.exercise == $ex)) | sort_by(.date) | last' $gym_data 2>/dev/null)
    
    if test -n "$last_entry" -a "$last_entry" != "null"
        set weight (echo $last_entry | jq -r '.weight')
        set reps (echo $last_entry | jq -r '.reps')
        set date (echo $last_entry | jq -r '.date')
        set tooltip "$tooltip• $exercise: $weight kg × $reps reps ($date)\\n"
    else
        set tooltip "$tooltip• $exercise: No data yet\\n"
    end
end

# Output JSON for Waybar
echo "{\"text\": \"◍\", \"tooltip\": \"$tooltip\", \"class\": \"gym-day\"}"
