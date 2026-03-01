# Source reminder script with delay after fish starts
function run_reminders --on-event fish_prompt
    set -g __reminders_run 1
    if test -f ~/scripts/remind.sh
        bash ~/scripts/remind.sh
    end
    functions -e run_reminders
end

# Only run if not already run in this session
if test -z "$__reminders_run"
    # Trigger on first prompt
    set -e __reminders_run
end