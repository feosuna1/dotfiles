set -x PAGER 'less'
set -x LESS '-R'
set -x LSCOLORS 'gxBxhxDxfxhxhxhxhxcxcx'
set -x CLICOLOR '1'
set -x GREP_OPTIONS '--color=auto'
set -x GREP_COLOR '1;32'
set -x LS_COLORS 'di=36:ln=01;31:ex=35'
set -x HOMEBREW_NO_ANALYTICS '1'

# Make sure homebrew environment shell variables are configured correctly.
eval "$(/opt/homebrew/bin/brew shellenv fish)"

# Setup our custom bin paths, only if they exist
set -l paths "$HOME/bin" "$HOME/.dotfiles/files/bin" 
for path in $paths
    if test -d $path; and not contains $path $fish_user_paths
        set --prepend fish_user_paths $path
    end
end
set -e paths

# Source all of our local configs, these configs are not stored in git repo and are local to
# the machine. This is a good spot to put secrets.
for path in $HOME/.config/fish/conf.local.d/*
    if test -f "$path"
        source "$path"
    end
end

if status --is-interactive
    if command -v code > /dev/null; and test -z (who am i | grep -E '\([0-9.]+\)$')
        set -x EDITOR 'code -w'
    else
        set -x EDITOR 'vi'
    end

    if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; and  [ "\$__CFBundleIdentifier" != "com.apple.Terminal" ]; and command -v oh-my-posh > /dev/null
        oh-my-posh init fish --config "$HOME/.dotfiles/files/config/oh-my-posh/default-theme.omp.json" | source
    end
end