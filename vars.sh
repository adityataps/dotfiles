#!/bin/bash

export DOTFILE_GITCONFIG_USER="$(git config --get user.name)"
export DOTFILE_GITCONFIG_EMAIL="$(git config --get user.email)"

# Prompt if not set (e.g. fresh machine with no existing git config)
if [[ -z "$DOTFILE_GITCONFIG_USER" ]]; then
    read -rp "Git user.name not configured. Enter your name: " DOTFILE_GITCONFIG_USER
    export DOTFILE_GITCONFIG_USER
fi

if [[ -z "$DOTFILE_GITCONFIG_EMAIL" ]]; then
    read -rp "Git user.email not configured. Enter your email: " DOTFILE_GITCONFIG_EMAIL
    export DOTFILE_GITCONFIG_EMAIL
fi
