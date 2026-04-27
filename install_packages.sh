#!/bin/bash

# Early exit if OS is not Darwin (macOS)
[ "$(uname -s)" != "Darwin" ] && echo "This script only runs on macOS" && exit 0

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BREWFILE="$SCRIPT_DIR/packages/Brewfile"

usage() {
    echo "Usage: $0 [--capture]"
    echo "Options:"
    echo "  --capture    Overwrite Brewfile with currently installed Homebrew packages"
    exit 1
}

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --capture)
            echo "Capturing installed packages -> $BREWFILE"
            brew bundle dump --force --file="$BREWFILE"
            echo "Done. Review and commit $BREWFILE."
            exit 0
            ;;
        *) echo "Unknown option: $arg"; usage ;;
    esac
done

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed."
fi

brew update
brew upgrade

# Install all packages from Brewfile
# HOMEBREW_CASK_OPTS=--adopt takes ownership of pre-existing apps not yet managed by Homebrew
HOMEBREW_CASK_OPTS="--adopt" brew bundle install --file="$BREWFILE"

brew cleanup

echo "Brew installation and package setup complete."
