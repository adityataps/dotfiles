#!/bin/bash
# Scripts to run after making dotfiles

# Git
git config --global user.name "$DOTFILE_GITCONFIG_USER"
git config --global user.email "$DOTFILE_GITCONFIG_EMAIL"
[ "$(uname -s)" = "Darwin" ] && git config --global credential.helper osxkeychain  

[[ -v GITCONFIG_SAFE_DIRECTORY ]] && find "$GITCONFIG_SAFE_DIRECTORY" -name '.git' -type d -exec bash -c 'git config --global --add safe.directory ${0%/.git}' {} \; || echo "GITCONFIG_SAFE_DIRECTORY is not set";

# Restart the current shell to use the updated configs
$SHELL
