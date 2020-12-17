function holler
    test $status = 0 && afplay /System/Library/Sounds/Glass.aiff -v 10 & || afplay /System/Library/Sounds/Submarine.aiff -v 10 &
end
