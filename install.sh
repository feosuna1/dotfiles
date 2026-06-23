#!/bin/bash
set -o errexit # Exit if any individual command fails and isn't handled
set -o nounset # Exit if unset variables are used

if [ -n "${BASH_VERSION:-}" ]; then
    # shellcheck disable=SC3040
    set -o pipefail # Exit if any command in a pipeline fails and isn't handled
fi

BIN_DIR="$HOME/.dotfiles/files/bin"
DOTFILES_DRY_RUN="${DOTFILES_DRY_RUN:-0}"
DOTFILES_SKIP_BREW="${DOTFILES_SKIP_BREW:-0}"

if [[ "$DOTFILES_DRY_RUN" != "1" ]]; then
    # shellcheck disable=SC1091
    source "$HOME/.dotfiles/files/sudo-support"
fi

# shellcheck disable=SC1091
source "$BIN_DIR/install-symlinks"
# shellcheck disable=SC1091
source "$BIN_DIR/install-copies"

if [[ "$DOTFILES_SKIP_BREW" == "1" || "$DOTFILES_DRY_RUN" == "1" ]]; then
    echo "Skipping Homebrew setup."
else
    # shellcheck disable=SC1091
    source "$BIN_DIR/install-brew"
fi

if [[ "$DOTFILES_DRY_RUN" == "1" ]]; then
    echo "Skipping system defaults and DNS configuration."
else
    # shellcheck disable=SC1091
    source "$BIN_DIR/configure-user-defaults"
    # shellcheck disable=SC1091
    source "$BIN_DIR/configure-dns-servers"
fi
