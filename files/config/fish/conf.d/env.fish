set -x PAGER 'less'
set -x LESS '-R'
set -x LSCOLORS 'gxBxhxDxfxhxhxhxhxcxcx'
set -x CLICOLOR '1'
set -x GREP_OPTIONS '--color=auto'
set -x GREP_COLOR '1;32'
set -x LS_COLORS 'di=36:ln=01;31:ex=35'
set -x HOMEBREW_NO_ANALYTICS '1'

if [ (who am i | grep -E '\([0-9.]+\)$') ]
    set -x EDITOR 'vi'
else
    set -x EDITOR 'code -w'
end

# Setup bin paths only if they exist
set -l paths $HOME/bin $HOME/.dotfiles/files/bin $HOME/.brew/bin
for path in $paths
    if test -d $path; and not contains $path $PATH
        set --prepend PATH $path
    end
end

# Setup ruby gems
set -x GEM_HOME $HOME/.gem/
if type -q gem
    for path in (string split : (gem environment gempath))
        set path "$path/bin"
        if test -d $path; and not contains $path $PATH
            test -d $path; and set --append PATH $path
        end
    end
end

for path in $HOME/.config/fish/conf.local.d/*
    if test -f "$path"
        source "$path"
    end
end
