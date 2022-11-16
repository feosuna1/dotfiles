# shellcheck shell=bash
export HOMEBREW_NO_ANALYTICS='1'

# Check that the specified directory exists – and is in the PATH.
# Setup bin paths only if they exist
paths=("$HOME/bin" "$HOME/.dotfiles/files/bin")
for p in "${paths[@]}"; do
    if [[ -d $p && ":$PATH:" != *:"$p":* ]]; then
        export PATH="$p:$PATH"
    fi
done

eval "$(/opt/homebrew/bin/brew shellenv)"