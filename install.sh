#!/usr/bin/env bash
#==================
set -o errexit # Exit if any individual command fails and isn't handled
set -o nounset # Exit if unset variables are used

if [ -n "${BASH_VERSION:-}" ]; then
    # If any command in a pipeline fails, the whole pipeline should fail.
    # This option isn't define by POSIX `sh` but is available if we're running
    # as `bash`.
    # Disable warning for using non-portable option (SC2039 for shellcheck <=
    # 0.7.1, SC3040 for >= 0.7.2).
    # shellcheck disable=SC2039,SC3040
    set -o pipefail
fi

kill_sudo_on_exit() {
    trap - EXIT

    # Invalidate the cached credentials, if we're the ones that cached it
    if [[ "$SUDO_CREDENTIALS_CACHED_IN_SCRIPT" -ne "0" ]]; then
        sudo -k
    fi

    # Kill all subprocesses
    kill -9 $(jobs -rp) 2> /dev/null
    wait $(jobs -rp) 2>/dev/null
}
trap kill_sudo_on_exit EXIT

ask_for_sudo_while_script_runs() {
    # Check to see the credentials were already cached before we got here.
    # When we exit, we want to make sure we only invalidate the credentials
    # if we were the ones that caused it to be cached.
    sudo -nv 2> /dev/null || rv=$?
    SUDO_CREDENTIALS_CACHED_IN_SCRIPT="$rv"

    sudo -v -p "Enter your password to install: "

    # This will create a background subprocess that will extends
    # sudo timeout every 5 seconds.
    (
        while sudo -nv 2> /dev/null; do
            sleep 5
        done
    )&
}

set_defaults_if_missing() {
    local domain=$1
    local key=$2
    local current_value=$(defaults read "$domain" "$key" 2> /dev/null || echo "")
    if [[ -z "$current_value" ]]; then
        shift 2
        defaults write "$domain" "$key" "$@"
    fi
}

make_and_install_roots() {
    TARGET_ROOT_DIR="$HOME"
    SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/roots"
    COPY_DIR="$SOURCE_DIR/copy/User"
    SYMLINK_DIR="$SOURCE_DIR/symlinks/User"

    find "$SYMLINK_DIR/" -type f \( ! -name ".DS_Store" \) | while read -d $'\n' symlink; do
        symlink=${symlink#*//}
        if [[ "$symlink" == *".symlink" ]]; then
            # A symlink file contains a single line representing the target to symlink to
            src=$(cat "$SYMLINK_DIR/$symlink")
            src="${src/#\~\/.dotfiles/$HOME}"
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
    [[ -f ~/.zshenv ]] && source ~/.zshenv
    [[ -f ~/.zprofile ]] && source ~/.zprofile
    [[ -f ~/.zshrc ]] && source ~/.zshrc
}

# -- Bootstrapping -------------------------------------------------------------

install_homebrew() {
    if command -v brew >/dev/null; then
        # Homebrew already installed.
        echo "Skipping homebrew, already installed."
        return
    fi

    echo "Installing homebrew and packages..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew analytics off || true
    brew update
    brew bundle install
}

configure_defaults() {
    # The following has been largely inspired by: https://github.com/mathiasbynens/dotfiles/blob/main/.macos

    # Close any open System Preferences panes, to prevent them from overriding settings being changed
    osascript -e 'tell application "System Preferences" to quit'

    # Enable dark mode, the following is set during Mac Buddy, we need to overwrite the value instead
    defaults write NSGlobalDomain AppleInterfaceStyle Dark

    # Show file extensions by default
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Expand save panel by default
    set_defaults_if_missing NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    set_defaults_if_missing NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Save to disk (not to iCloud) by default
    set_defaults_if_missing NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Expand print panel by default
    set_defaults_if_missing NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    set_defaults_if_missing NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Automatically quit printer app once the print jobs complete
    set_defaults_if_missing com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    # Disable the “Are you sure you want to open this application?” dialog
    set_defaults_if_missing com.apple.LaunchServices LSQuarantine -bool false

    # Trackpad, mouse, keyboard, Bluetooth accessories, and input
    # The following settings are seeded by the operating system, so we need to overwrite the values instead
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking 0
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad DragLock 0
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging 0
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick 0
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadHandResting 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadHorizScroll 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadMomentumScroll 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadPinch 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRotate 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadScroll 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag 0
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerDoubleTapGesture 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture 3
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad USBMouseStopsTrackpad 0
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad UserPreferences 1

    # Use list view in all Finder windows by default
    set_defaults_if_missing com.apple.finder FXPreferredViewStyle -string "Nlsv"
    set_defaults_if_missing com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Enable AirDrop over Ethernet and on unsupported Macs running Lion
    set_defaults_if_missing com.apple.NetworkBrowser BrowseAllInterfaces -bool true

    # Show the ~/Library folder
    chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

    # Show the /Volumes folder
    sudo chflags nohidden /Volumes
}

ask_for_sudo_while_script_runs
make_and_install_roots
install_homebrew
configure_defaults
