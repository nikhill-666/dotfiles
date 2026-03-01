function cls
    if test -z "$argv[1]"
        echo "Usage: cls <num>"
    else
        sed -i "$argv[1]d" ~/.reminders
        echo "Task $argv[1] cleared."
    end
end