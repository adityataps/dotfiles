#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BREWFILE="$SCRIPT_DIR/packages/Brewfile"
mode=install

usage() {
    printf 'Usage: %s [--capture | --upgrade | --help]\n' "$0"
    printf 'Default: install missing Brewfile packages without upgrading existing ones.\n'
}
[[ $# -le 1 ]] || { usage >&2; exit 1; }
case "${1:-}" in
    '') ;;
    --capture) mode=capture ;;
    --upgrade) mode=upgrade ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
esac

[[ "$(uname -s)" = Darwin ]] || { printf 'Package installation requires macOS.\n' >&2; exit 1; }

# A new terminal may not have Homebrew on PATH yet (Apple Silicon or Intel).
if ! command -v brew >/dev/null 2>&1; then
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$brew_bin" ]]; then
            eval "$("$brew_bin" shellenv)"
            break
        fi
    done
fi
command -v brew >/dev/null 2>&1 || {
    printf 'Homebrew not found. Run bootstrap.sh or install it from https://brew.sh.\n' >&2
    exit 1
}

case "$mode" in
    capture)
        brew bundle dump --force --file="$BREWFILE"
        printf 'Captured packages. Review %s before committing.\n' "$BREWFILE"
        ;;
    upgrade)
        brew update
        brew bundle upgrade --file="$BREWFILE"
        ;;
    install)
        brew bundle install --no-upgrade --file="$BREWFILE"
        ;;
esac
