# shellcheck shell=bash
export PAGER='less'
export LESS='-R'
export LSCOLORS='gxBxhxDxfxhxhxhxhxcxcx'
export CLICOLOR='1'
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'
export LS_COLORS='di=36:ln=01;31:ex=35'
export HOMEBREW_NO_ANALYTICS='1'

# Check that the specified directory exists – and is in the PATH.
# Setup bin paths only if they exist
paths=("$HOME/bin" "$HOME/.dotfiles/files/bin" "$HOME/.brew/bin")
for p in "${paths[@]}"; do
    if [[ -d $p && ":$PATH:" != *:"$p":* ]]; then
        export PATH="$p:$PATH"
    fi
done

if ! command -v code > /dev/null; then
    export EDITOR='vi'
else
    export EDITOR='code -w'
fi

zstyle ':completion:*:*:git:*' script "$HOME/.dotfiles/files/config/zsh/git-completion.bash"
# shellcheck disable=SC2206
fpath=("$HOME/.dotfiles/files/config/zsh" ${fpath[@]}) 
autoload -Uz compinit && compinit
