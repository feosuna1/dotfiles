set -x PAGER 'less'
set -x LESS '-R'
set -x LSCOLORS 'gxBxhxDxfxhxhxhxhxcxcx'
set -x CLICOLOR '1'
set -x GREP_OPTIONS '--color=auto'
set -x GREP_COLOR '1;32'
set -x LS_COLORS 'di=36:ln=01;31:ex=35'
set -x HOMEBREW_NO_ANALYTICS '1'

# Remove the Homebrew paths from `PATH` because `brew shellenv` will prepend duplicates, this will
# happen if subshells are created and the homebrew paths are not in the beginning of the search path
if set -q HOMEBREW_PREFIX
    set -l homebrew_paths "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
    set -l paths $PATH

    for homebrew_path in $homebrew_paths
        set -l index $(contains -i $homebrew_path $paths)
        if test -n "$index"
            set -e paths[$index]
        end
    end

    set -x PATH $paths

    set -e homebrew_paths
    set -e paths
end

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