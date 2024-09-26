#!/bin/bash

# .gitconfig
export DOTFILE_GITCONFIG_USER="$(git config --get user.name)"
export DOTFILE_GITCONFIG_EMAIL="$(git config --get user.email)"
