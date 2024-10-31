#!/bin/bash

# Install Homebrew if it's not already installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed."
fi

# Make sure we're using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# List of packages to install
packages=(
    tree
    git
    mosh
    docker
    zsh
    zsh-autocomplete
    node
#    terraform
    opentofu
    python
    pyenv
    pipx
    dbeaver-community
)

# Install packages
for package in "${packages[@]}"; do
    if brew list "$package" &>/dev/null; then
        echo "${package} is already installed."
    else
        echo "Installing ${package}..."
        brew install "$package"
    fi
done

# Cleanup
brew cleanup

echo "Brew installation and package setup complete."
