# --- Simple Reminder System ---

function remind
    set -l category "any"
    if test "$argv[1]" = "-w"
        set category "work"
        set -e argv[1]
    else if test "$argv[1]" = "-p"
        set category "play"
        set -e argv[1]
    end

    echo "$category | "(date '+%d/%m')" | $argv" >> ~/.reminders
    echo "Added to $category list."
end

function cls
    if test -z "$argv[1]"
        echo "Usage: cls <num>"
    else
        sed -i "$argv[1]d" ~/.reminders
        echo "Task $argv[1] cleared."
    end
end