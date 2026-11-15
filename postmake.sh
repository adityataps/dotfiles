#!/bin/bash
# Initialize machine-local Git settings without overwriting existing preferences.
set -euo pipefail
GITCONFIG_LOCAL="$HOME/.gitconfig.local"
if [[ -e "$GITCONFIG_LOCAL" || -L "$GITCONFIG_LOCAL" ]]; then
    [[ -f "$GITCONFIG_LOCAL" ]] || { printf 'Invalid Git config: %s\n' "$GITCONFIG_LOCAL" >&2; exit 1; }
    git config --file "$GITCONFIG_LOCAL" --list >/dev/null
    # Preserve local preferences; fill only missing identity fields from vars.sh.
    if [[ -z "$(git config --file "$GITCONFIG_LOCAL" --includes --get user.name || true)" && -n "${DOTFILE_GITCONFIG_USER:-}" ]]; then
        git config --file "$GITCONFIG_LOCAL" user.name "$DOTFILE_GITCONFIG_USER"
    fi
    if [[ -z "$(git config --file "$GITCONFIG_LOCAL" --includes --get user.email || true)" && -n "${DOTFILE_GITCONFIG_EMAIL:-}" ]]; then
        git config --file "$GITCONFIG_LOCAL" user.email "$DOTFILE_GITCONFIG_EMAIL"
    fi
    exit 0
fi

[[ -n "${DOTFILE_GITCONFIG_USER:-}" && -n "${DOTFILE_GITCONFIG_EMAIL:-}" ]] || {
    printf 'Missing Git identity; run make_dotfiles.sh first.\n' >&2
    exit 1
}

# Git handles quoting names containing quotes, comment characters, or whitespace.
umask 077
local_config_tmp="$(mktemp "$HOME/.gitconfig.local.XXXXXX")"
trap 'rm -f "$local_config_tmp"' EXIT
git config --file "$local_config_tmp" user.name "$DOTFILE_GITCONFIG_USER"
git config --file "$local_config_tmp" user.email "$DOTFILE_GITCONFIG_EMAIL"
if [[ "$(uname -s)" = Darwin ]]; then
    git config --file "$local_config_tmp" credential.helper osxkeychain
fi
mv "$local_config_tmp" "$GITCONFIG_LOCAL"
printf 'Created %s\n' "$GITCONFIG_LOCAL"
