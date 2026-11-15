#!/bin/bash
# Sourced only when deploying .gitconfig. Never capture repository overrides.
dotfile_local_user=""
dotfile_local_email=""
if [[ -e "$HOME/.gitconfig.local" || -L "$HOME/.gitconfig.local" ]]; then
    [[ -f "$HOME/.gitconfig.local" ]] || { printf 'Invalid ~/.gitconfig.local\n' >&2; return 1; }
    git config --file "$HOME/.gitconfig.local" --list >/dev/null || return 1
    dotfile_local_user="$(git config --file "$HOME/.gitconfig.local" --includes --get user.name || true)"
    dotfile_local_email="$(git config --file "$HOME/.gitconfig.local" --includes --get user.email || true)"
fi
DOTFILE_GITCONFIG_USER="${dotfile_local_user:-${DOTFILE_GITCONFIG_USER:-$(git config --global --includes --get user.name || true)}}"
DOTFILE_GITCONFIG_EMAIL="${dotfile_local_email:-${DOTFILE_GITCONFIG_EMAIL:-$(git config --global --includes --get user.email || true)}}"
export DOTFILE_GITCONFIG_USER DOTFILE_GITCONFIG_EMAIL

if [[ -z "$DOTFILE_GITCONFIG_USER" || -z "$DOTFILE_GITCONFIG_EMAIL" ]]; then
    if [[ ! -t 0 ]]; then
        printf 'Set DOTFILE_GITCONFIG_USER and DOTFILE_GITCONFIG_EMAIL before noninteractive setup.\n' >&2
        return 1
    fi
    [[ -n "$DOTFILE_GITCONFIG_USER" ]] || read -r -p 'Git user.name: ' DOTFILE_GITCONFIG_USER
    [[ -n "$DOTFILE_GITCONFIG_EMAIL" ]] || read -r -p 'Git user.email: ' DOTFILE_GITCONFIG_EMAIL
    [[ -n "$DOTFILE_GITCONFIG_USER" && -n "$DOTFILE_GITCONFIG_EMAIL" ]] || return 1
fi
