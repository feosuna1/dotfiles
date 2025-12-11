set -gx PAGER 'less'
set -gx LESS '-R'
set -gx LSCOLORS 'gxBxhxDxfxhxhxhxhxcxcx'
set -gx CLICOLOR '1'
set -gx GREP_OPTIONS '--color=auto'
set -gx GREP_COLOR '1;32'
set -gx LS_COLORS 'di=36:ln=01;31:ex=35'
set -gx HOMEBREW_NO_ANALYTICS '1'

# Do not use fish_add_path because it potentially changes the order of items in PATH
function __prepend_path
    set -l path $argv[1]
    set -l index (contains -i -- $path $PATH)
    if set -q index[1]
        set -e PATH[$index]
    end

    if test -d $path
        set -gx --prepend PATH $path
    end
end

# Source all of our local configs, these configs are not stored in git repo and are local to
# the machine. This is a good spot to put secrets.
for path in $HOME/.config/fish/conf.local.d/*
    if test -f "$path"
        source "$path"
    end
end

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    __prepend_path "$HOME/.asdf/shims"
else
    __prepend_path "$ASDF_DATA_DIR/shims"
end

# Make sure homebrew environment shell variables are configured correctly.
if test -f "/opt/homebrew/bin/brew"
    eval "$(/opt/homebrew/bin/brew shellenv fish)"
end

# Setup our custom bin paths, only if they exist
for path in "$HOME/bin" "$HOME/.dotfiles/files/bin"
    __prepend_path $path
end

if status --is-interactive
    if command -v code > /dev/null; and test -z (who am i | grep -E '\([0-9.]+\)$')
        set -gx EDITOR 'code -w'
    else
        set -gx EDITOR 'vi'
    end
end
