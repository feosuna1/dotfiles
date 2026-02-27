#!/usr/bin/env fish

# A Claude Code status bar script that shows:
#   - Path + branch — fish-style abbreviated path, * if dirty
#   - Model — white (Sonnet), light blue (Opus), yellow (other), bright red (large context)
#   - Context % — white ≤65%, gradients to bright red at 95%+
#   - Cost — white ≤$2, gradients to bright red at $15+, ⚠️ above $20, ❗ above $30

function model_color -a model
    # Model color (large context check must come first)
    switch $model
        case '*[Ll]arge*' '*[Ll]ong*' '*1[Mm]*' '*[Ee]xtended*'
            set_color --bold brred
        case '*[Ss]onnet*'
            set_color white
        case '*[Oo]pus*'
            set_color brblue
        case '*'
            set_color yellow
    end
end

# Pick a color on a white->yellow->red gradient based on a 0-1 scaled value
function pick_gradient_color -a scaled
    if [ $scaled -le 0.5 ]
        # White -> Yellow
        set t (math "$scaled * 2")
        set r1 (math "0xFF")
        set g1 (math "0xFF")
        set b1 (math "0xFF")

        set r2 (math "0xFF")
        set g2 (math "0xFF")
        set b2 (math "0x00")
    else
        # Yellow -> Red
        set t (math "($scaled - 0.5) * 2")
        set r1 (math "0xFF")
        set g1 (math "0xFF")
        set b1 (math "0x01")

        set r2 (math "0xFF")
        set g2 (math "0x00")
        set b2 (math "0x00")
    end

    printf "%02x%02x%02x" \
        (math "round($r1 + ($r2 - $r1) * $t)") \
        (math "round($g1 + ($g2 - $g1) * $t)") \
        (math "round($b1 + ($b2 - $b1) * $t)")
end

# Scaled color: white ≤ lower, bright red ≥ upper, gradient in between
function scaled_color -a lower upper value
    if [ $value -le $lower ]
        set_color white
    else if [ $value -ge $upper ]
        set_color --bold brred
    else
        set -l scaled (math "($value - $lower) / ($upper - $lower)")
        set_color (pick_gradient_color $scaled)
    end
end

# Cost color: white until $2, gradient white->yellow->red over $2-$15, bright red at $15+
function cost_color -a cost
    scaled_color 2 15 $cost
end

# Context color: white until 65%, gradient white->yellow->red over 65-95%, bright red at 95%+
function context_color -a pct
    scaled_color 65 83 $pct
end

jq -r '[.model.display_name // "Unknown Model", .cost.total_cost_usd // 0, .context_window.used_percentage // 0] | @tsv' \
    | read -l -d \t model session_cost context_window_percentage

set -l warning ""
if [ $session_cost -ge 30 ]
    set warning " ❗"
else if [ $session_cost -ge 20 ]
    set warning " ⚠️"
end

set -l separator " | "

set_color $fish_color_cwd; echo -n (prompt_pwd); set_color normal; fish_vcs_prompt; echo -n $separator
model_color $model; echo -n $model; set_color normal; echo -n $separator
context_color $context_window_percentage; echo -n "$context_window_percentage%"; set_color normal; echo -n $separator
cost_color $session_cost; printf "\$%.4f%s" $session_cost $warning; set_color normal
