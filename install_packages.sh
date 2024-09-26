#!/bin/bash

# Install Homebrew if it's not already installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Make sure we're using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# List of packages to install
packages=(
    git
    mosh
    docker
    zsh
    zsh-autocomplete
    node
    pnpm
    terraform
    python
    pyenv
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
