#!/usr/bin/env bash
#==================
set -ex

kill_sudo_on_exit() {
    trap - EXIT

    # Invalidate cached credentials if we're the ones that cached it
    if [[ "$SUDO_CREDENTIALS_CACHED_IN_SCRIPT" -ne "0" ]]; then
        sudo -k
    fi

    # Kill all subprocesses
    kill -9 $(jobs -rp) 2> /dev/null
    wait $(jobs -rp) 2>/dev/null
}
trap kill_sudo_on_exit EXIT

ask_for_sudo_while_script_runs() {
    sudo -nv 2> /dev/null || rv=$?
    SUDO_CREDENTIALS_CACHED_IN_SCRIPT="$rv"

    sudo -v -p "Enter your password to install: "

    # Stash away the current PID so that the sub-shell can exit if it ran
    # away from it's parent. This can happen when set -e is enabled
    # and bash decided to exit immeidately by-passing the signal handlers
    (
        set +ex
        while sudo -nv 2> /dev/null; do
            sleep 5
        done
    )&
    SUDO_PID="$!"
}

write_to_defaults_if_needed() {
    local domain=$1
    local key=$2
    local current_value=$(defaults read "$domain" "$key" 2> /dev/null || echo "")
    if [[ -z "$current_value" ]]; then
        shift 2
        defaults write "$domain" "$key" "$@"
    fi
}

make_and_install_roots() {
    TARGET_ROOT_DIR=`mktemp -d`
    SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/roots"
    COPY_DIR="$SOURCE_DIR/copy/User"
    SYMLINK_DIR="$SOURCE_DIR/symlinks/User"

    echo "Assembling the root..."
    mkdir -p "$TARGET_ROOT_DIR"
    cp -R "$COPY_DIR/" "$TARGET_ROOT_DIR/User/"

    find "$SYMLINK_DIR/" -type f \( ! -name ".DS_Store" \) | while read -d $'\n' symlink; do
        symlink=${symlink#*//}
        if [[ "$symlink" == *".symlink" ]]; then
            src=$(cat "$SYMLINK_DIR/$symlink")
            src="${src/#\~/$HOME}"
            dest="$TARGET_ROOT_DIR/User/${symlink%.symlink}"
        else
            src="$SYMLINK_DIR/$symlink"
            dest="$TARGET_ROOT_DIR/User/$symlink"
        fi

        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
    done

    echo "Archiving the root..."
    ARCHIVE="$TARGET_ROOT_DIR/user-dotfiles.tar.gz"
    tar -czvf "$ARCHIVE" -C "$TARGET_ROOT_DIR/User/" . 2> /dev/null

    echo "Attempting to upgrade existing root..."
    rv=0
    sudo darwinup -df -p "$HOME" upgrade "$ARCHIVE" > /dev/null || rv=$?
    if [ $rv -eq 5 ]; then
        echo "Upgrade failed. Installing root instead..."
        sudo darwinup -df -p "$HOME" install "$ARCHIVE"
    fi

    rm -fr "$TARGET_ROOT_DIR"
}

install_homebrew() {
    if [[ ! $(cat ~/.profile | grep .brew/bin) ]]; then
        # So we use all of the packages we are about to install
        echo "export PATH=\"\$HOME/.brew/bin:\$PATH\"" >> ~/.profile
    fi

    if [[ $PATH != *".brew/bin"* ]]; then
        export PATH=$HOME/.brew/bin:$PATH
    fi

    brew=$(which brew) || true
    if [[ -z "$brew" ]]; then
        echo "Installing homebrew and packages..."
        git clone https://github.com/Homebrew/brew.git "$HOME/.brew/"
        brew analytics off
        brew update
    else
        echo "Skipping homebrew, already installed."
    fi
}

_install_brew_if_needed() {
    # if the package is installed, skip it
    if brew list "$@" &>/dev/null; then
        echo "Skipping $@"
    else
        echo "Installing $@"
        brew install "$@"
    fi
}

_install_cask_if_needed() {
    # if the package is installed, skip it
    if brew cask list "$@" &>/dev/null; then
        echo "Skipping $@"
    else
        echo "Installing $@"
        brew cask install --appdir="/Applications" "$@"
    fi
}

install_homebrew_packages() {
    local brews=(fish jq wget)
    local casks=(iterm2 visual-studio-code)
    for brew in ${brews[@]}; do
        _install_brew_if_needed "$brew"
    done

    for cask in ${casks[@]}; do
        _install_cask_if_needed "$cask"
    done

    brew upgrade
}

configure_fish() {
    local fish=$(which fish)
    if [[ "$SHELL" != "$fish" ]]; then
        echo "Configuring Fish Shell..."
        sudo chsh -s "$fish" "$USER"
    else
        echo "Shell already set to fish."
    fi
}

configure_defaults() {
    # The following has been largely inspired by: https://github.com/mathiasbynens/dotfiles/blob/main/.macos

    # Close any open System Preferences panes, to prevent them from overriding settings being changed
    osascript -e 'tell application "System Preferences" to quit'

    # Enable dark mode, the following is set during Mac Buddy, we need to overwrite the value instead
    defaults write NSGlobalDomain AppleInterfaceStyle Dark

    # Expand save panel by default
    write_to_defaults_if_needed NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    write_to_defaults_if_needed NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Save to disk (not to iCloud) by default
    write_to_defaults_if_needed NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Expand print panel by default
    write_to_defaults_if_needed NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    write_to_defaults_if_needed NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Automatically quit printer app once the print jobs complete
    write_to_defaults_if_needed com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    # Disable the “Are you sure you want to open this application?” dialog
    write_to_defaults_if_needed com.apple.LaunchServices LSQuarantine -bool false

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
    write_to_defaults_if_needed com.apple.finder FXPreferredViewStyle -string "Nlsv"
    write_to_defaults_if_needed com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Enable AirDrop over Ethernet and on unsupported Macs running Lion
    write_to_defaults_if_needed com.apple.NetworkBrowser BrowseAllInterfaces -bool true

    # Show the ~/Library folder
    chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

    # Show the /Volumes folder
    sudo chflags nohidden /Volumes

    # Update Xcode to use custom theme
    if [[ -f "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/Dracula.xccolortheme" ]]; then
        write_to_defaults_if_needed com.apple.dt.Xcode XCFontAndColorCurrentTheme -string "Dracula.xccolortheme"
    fi
}

ask_for_sudo_while_script_runs
make_and_install_roots
install_homebrew
install_homebrew_packages
configure_fish
configure_defaults