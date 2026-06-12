#!/bin/bash
set -o errexit # Exit if any individual command fails and isn't handled
set -o nounset # Exit if unset variables are used

if [ -n "${BASH_VERSION:-}" ]; then
    # shellcheck disable=SC3040
    set -o pipefail # Exit if any command in a pipeline fails and isn't handled
fi

# shellcheck source=files/sudo-support
source "$HOME/.dotfiles/files/sudo-support"
BIN_DIR="$HOME/.dotfiles/files/bin"

make_and_install_roots() {
    TARGET_ROOT_DIR="$HOME"
    SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/roots"
    COPY_DIR="$SOURCE_DIR/copy/User"
    SYMLINK_DIR="$SOURCE_DIR/symlinks/User"

    find "$SYMLINK_DIR/" -type f \( ! -name ".DS_Store" \) | while read -r -d $'\n' symlink; do
        symlink="${symlink#"$SYMLINK_DIR"/}"
        if [[ "$symlink" == *".symlink" ]]; then
            # A symlink file contains a single line representing the target to symlink to
            src=$(cat "$symlink")
            src="${src/#\~/$HOME}"
            dest="$TARGET_ROOT_DIR/${symlink%.symlink}"
        else
            src="$SYMLINK_DIR/$symlink"
            dest="$TARGET_ROOT_DIR/$symlink"
        fi

        # Only create the symlink if the source file or directory exists
        if [[ -f "$src" || -d "$src" ]] && [[ ! -f "$dest" ]]; then
            mkdir -p "$(dirname "$dest")"
            ln -sf "$src" "$dest"
        fi
    done

    rsync -razI --ignore-existing --progress "$COPY_DIR/" "$HOME"

    # shellcheck disable=all
    [[ -f ~/.bash_profile ]] && source ~/.bash_profile

    # shellcheck disable=all
    [[ -f ~/.bashrc ]] && source ~/.bashrc
}

make_and_install_roots
source "$BIN_DIR/install-brew"
source "$BIN_DIR/configure-user-defaults"
source "$BIN_DIR/configure-dns-servers"
