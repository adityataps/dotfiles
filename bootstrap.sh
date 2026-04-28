#!/bin/bash
# Bootstrap a fresh macOS machine with dotfiles.
# Run this once on a new machine:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/adityataps/dotfiles/main/bootstrap.sh)"

set -e

DOTFILES_REPO="https://github.com/adityataps/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "==> Bootstrapping dotfiles"

# Xcode Command Line Tools (provides git, make, etc.)
if ! xcode-select -p &>/dev/null; then
    echo "==> Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "    Waiting for Xcode CLT installation to complete..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    echo "    Xcode CLT installed."
else
    echo "==> Xcode CLT already installed."
fi

# Homebrew
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "==> Homebrew already installed."
fi

# git (CLT provides a stub; get the real one)
if ! brew list git &>/dev/null; then
    echo "==> Installing git..."
    brew install git
fi

# Clone dotfiles
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "==> Cloning dotfiles into $DOTFILES_DIR..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo "==> Dotfiles already cloned at $DOTFILES_DIR — pulling latest..."
    git -C "$DOTFILES_DIR" pull origin main
fi

# Deploy
echo "==> Running make_dotfiles.sh -i..."
"$DOTFILES_DIR/make_dotfiles.sh" -i

echo ""
echo "Bootstrap complete."
