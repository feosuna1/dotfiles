# shellcheck shell=bash
source ~/.dotfiles/files/config/zsh/login.zsh

export PAGER='less'
export LESS='-R'
export LSCOLORS='gxBxhxDxfxhxhxhxhxcxcx'
export CLICOLOR='1'
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'
export LS_COLORS='di=36:ln=01;31:ex=35'
export HOMEBREW_NO_ANALYTICS='1'

if command -v code > /dev/null; then
    export EDITOR='code -w'
else
    export EDITOR='vi'
fi

if [ -f ~/.fzf.zsh ]; then
    # shellcheck disable=SC1091
    source "$HOME/.fzf.zsh"
fi

zstyle ':completion:*:*:git:*' script "$HOME/.dotfiles/files/config/zsh/git-completion.bash"
# shellcheck disable=SC2206
fpath=("$HOME/.dotfiles/files/config/zsh" ${fpath[@]}) 
autoload -Uz compinit && compinit

# Custom key bindings that match up with tmux.conf
clear-screen-and-backbuffer(){
    clear
    printf "\ec\e[3J"
    zle reset-prompt
}
zle -N clear-screen-and-backbuffer{,}
bindkey '^L' 'clear-screen-and-backbuffer'
