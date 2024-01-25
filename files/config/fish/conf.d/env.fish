set -x PAGER 'less'
set -x LESS '-R'
set -x LSCOLORS 'gxBxhxDxfxhxhxhxhxcxcx'
set -x CLICOLOR '1'
set -x GREP_OPTIONS '--color=auto'
set -x GREP_COLOR '1;32'
set -x LS_COLORS 'di=36:ln=01;31:ex=35'
set -x HOMEBREW_NO_ANALYTICS '1'

# Remove brew and asdf paths from `PATH` because `brew shellenv` will prepend duplicates and `asdf.fish` will not
# not guaruntee that the asdf shim paths are prepended. This is most apparent in subshells (e.g., tmux sessions).
set -l _remove_paths
if test -n "$HOMEBREW_PREFIX"
    # Add the brew paths
    set -a _remove_paths "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
end

if test -n "$ASDF_DIR"
    # Add the asdf paths
    set -a _remove_paths "$ASDF_DIR/bin"
    if test -z $ASDF_DATA_DIR
        set -a _remove_paths "$HOME/.asdf/shims"
    else
        set -a _remove_paths "$ASDF_DATA_DIR/shims"
    end
end

if test -n "$_remove_paths"
    set -l paths $PATH
    for _remove_path in $_remove_paths
        set -l index $(contains -i $_remove_path $paths)
        if test -n "$index"
            set -e paths[$index]
        end
    end
    set -x PATH $paths
    set -e paths
end
set -e _remove_paths

# Make sure homebrew environment shell variables are configured correctly.
if test -f "/opt/homebrew/bin/brew"
    eval "$(/opt/homebrew/bin/brew shellenv fish)"
end

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

if test -f "/opt/homebrew/opt/asdf/libexec/asdf.fish"
    source /opt/homebrew/opt/asdf/libexec/asdf.fish
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