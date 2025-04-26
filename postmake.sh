#!/bin/bash
# Scripts to run after making dotfiles

# Git
git config --global user.name "$DOTFILE_GITCONFIG_USER"
git config --global user.email "$DOTFILE_GITCONFIG_EMAIL"

# Restart the current shell to use the updated configs
$SHELL
