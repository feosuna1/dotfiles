set -x PAGER 'less'
set -x LESS '-R'
set -x LSCOLORS 'gxBxhxDxfxhxhxhxhxcxcx'
set -x CLICOLOR '1'
set -x GREP_OPTIONS '--color=auto'
set -x GREP_COLOR '1;32'
set -x LS_COLORS 'di=36:ln=01;31:ex=35'
set -x HOMEBREW_NO_ANALYTICS '1'

set -l is_ssh (who am i | grep -E '\([0-9.]+\)$')
if [ $is_ssh ]
    set -x EDITOR 'vi'
else
    set -x EDITOR 'code -w'
end

# Setup paths only if they exist
set -l paths $HOME/bin $HOME/.dotfiles/files/bin $HOME/.brew/bin
for path in $paths
    test -d $path; and set -x PATH $path $PATH
end

# Setup ruby gems
set -x GEM_HOME $HOME/.gem/
if type -q gem
    set -l gempaths (string split : (gem environment gempath))
    for path in $gempaths
        set path "$path/bin"
        test -d $path; and set -x PATH $PATH $path
    end
end
