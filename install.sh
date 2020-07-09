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

install_fish() {
    fish=$(which fish) || true
    if [[ -z "$fish" ]]; then
        echo "Installing fish..."
        brew install fish
        fish=$(which fish)
    else
        echo "Skipping fish, already installed."
    fi

    if [[ "$SHELL" != "$fish" ]]; then
        echo "Configuring Fish Shell..."
        sudo chsh -s "$fish" "$USER"
    else
        echo "Shell already set to fish."
    fi
}

install_jq() {
    jq=$(which jq) || true
    if [[ -z "$fish" ]]; then
        echo "Installing jq..."
        brew install jq
    else
        echo "Skipping jq, already installed."
    fi
}

download_and_install() {
    local APP="$1"
    if [[ ! -d "/Applications/$APP.app/" ]]; then
        local URL="$2"
        local FILENAME="$3"
        local SHA="$4"

        echo "Download $APP..."
        curl -L "$URL" > "$FILENAME"
        echo "$SHA *$FILENAME" | shasum -c
        if [ $? == 0 ]; then
            unzip $FILENAME -d /Applications
        else
            echo "Downloaded $APP doesn't match the expected SHA"
        fi
        rm $FILENAME
    else
        echo "Skipping $APP, already installed."
    fi
}

install_iterm() {
    download_and_install "iTerm" "https://iterm2.com/downloads/stable/iTerm2-3_3_12.zip" "/tmp/iTerm2-3_3_12.zip" "7280aa13a8f08c2c9809f8e973064988e559dd3b"
}

install_visual_studio_code() {
    download_and_install "Visual Studio Code" "https://update.code.visualstudio.com/1.46.1/darwin/stable" "/tmp/vsc-1.46.1.zip" "5b2a72fb5301fbb60ac8777177540aee35e87138"
}

configure_xcode() {
    current_theme=$(defaults read com.apple.dt.Xcode XCFontAndColorCurrentTheme 2> /dev/null || echo "")
    if [[ -f "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/Dracula.xccolortheme" && -z "$current_theme" ]]; then
        echo "Configuring Xcode Theme..."
        defaults write com.apple.dt.Xcode XCFontAndColorCurrentTheme -string "Dracula.xccolortheme"
    else
        echo "Skipping Xcode configuration, already configured."
    fi
}

ask_for_sudo_while_script_runs
make_and_install_roots
install_homebrew
install_fish
install_jq
install_iterm
install_visual_studio_code
configure_xcode