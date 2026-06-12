#!/bin/bash
# set -x
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
            src=$(cat "$SYMLINK_DIR/$symlink")
            src="${src/#\~/$HOME}"
            dest="$TARGET_ROOT_DIR/${symlink%.symlink}"
        else
            src="$SYMLINK_DIR/$symlink"
            dest="$TARGET_ROOT_DIR/$symlink"
        fi

        # Only create the symlink if the source file or directory exists
        if [[ -f "$src" ]] && [[ ! -f "$dest" ]]; then
            echo "Linking \"$symlink\"..."
            mkdir -p "$(dirname "$dest")"
            ln -sf "$src" "$dest"
        else
            echo "Skipping \"$symlink\"..."
        fi
    done

    echo "Copying \"$COPY_DIR\" to \"$HOME\"..."
    rsync -razI --ignore-existing --progress "$COPY_DIR/" "$HOME"
}

make_and_install_roots
source "$BIN_DIR/install-brew"
source "$BIN_DIR/configure-user-defaults"
source "$BIN_DIR/configure-dns-servers"
