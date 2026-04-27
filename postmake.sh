#!/bin/bash
# Scripts to run after making dotfiles

# Git: write machine-specific identity to ~/.gitconfig.local (not tracked in repo)
# This keeps name/email out of dotfiles/.gitconfig when it's symlinked.
GITCONFIG_LOCAL="$HOME/.gitconfig.local"
if [[ ! -f "$GITCONFIG_LOCAL" ]]; then
    echo "Creating $GITCONFIG_LOCAL with identity from vars.sh..."
    cat > "$GITCONFIG_LOCAL" <<EOF
[user]
	name = $DOTFILE_GITCONFIG_USER
	email = $DOTFILE_GITCONFIG_EMAIL
EOF
    echo "Created $GITCONFIG_LOCAL"
else
    echo "$GITCONFIG_LOCAL already exists — skipping identity write."
    echo "Edit it manually to change user.name / user.email."
fi

# macOS keychain credential helper
[ "$(uname -s)" = "Darwin" ] && git config --file "$GITCONFIG_LOCAL" credential.helper osxkeychain

# Restart the current shell to use the updated configs
$SHELL
