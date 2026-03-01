function fish_greeting
    # Source reminder script if it exists
    if test -f ~/scripts/remind.sh
        bash ~/scripts/remind.sh
    end
end