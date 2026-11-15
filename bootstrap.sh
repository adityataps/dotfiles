#!/bin/bash
# Bootstrap a fresh Mac. Review this script before running it.
set -euo pipefail
DOTFILES_REPO="https://github.com/adityataps/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

case "${1:-}" in
    -h|--help)
        printf 'Usage: %s\nClones into %s and runs full setup.\n' "$0" "$DOTFILES_DIR"
        exit 0
        ;;
    '') ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 1 ;;
esac
[[ $# -le 1 ]] || exit 1
[[ "$(uname -s)" = Darwin ]] || { printf 'Bootstrap requires macOS.\n' >&2; exit 1; }

# Check an existing checkout before installing anything or pulling updates.
if [[ -e "$DOTFILES_DIR" || -L "$DOTFILES_DIR" ]]; then
    if [[ ! -d "$DOTFILES_DIR/.git" ]] || ! git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf 'Refusing existing non-checkout directory: %s\n' "$DOTFILES_DIR" >&2
        exit 1
    fi
    origin="$(git -C "$DOTFILES_DIR" remote get-url origin)"
    case "$origin" in
        https://github.com/adityataps/dotfiles.git|https://github.com/adityataps/dotfiles|git@github.com:adityataps/dotfiles.git) ;;
        *) printf 'Existing checkout has an unexpected origin: %s\n' "$origin" >&2; exit 1 ;;
    esac
    if [[ -n "$(git -C "$DOTFILES_DIR" status --porcelain)" || "$(git -C "$DOTFILES_DIR" symbolic-ref --quiet --short HEAD)" != main ]]; then
        printf 'Existing checkout must be clean and on main; update it manually first.\n' >&2
        exit 1
    fi
fi

if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
    printf 'Finish installing Xcode Command Line Tools, then rerun this script.\n'
    exit 1
fi

# Detect either Homebrew prefix before attempting installation.
if ! command -v brew >/dev/null 2>&1; then
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$brew_bin" ]]; then
            eval "$("$brew_bin" shellenv)"
            break
        fi
    done
fi
if ! command -v brew >/dev/null 2>&1; then
    installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    /bin/bash -c "$installer"
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        printf 'Homebrew installation did not produce a usable brew executable.\n' >&2
        exit 1
    fi
fi

if [[ -d "$DOTFILES_DIR/.git" ]]; then
    git -C "$DOTFILES_DIR" pull --ff-only origin main
else
    git clone --branch main "$DOTFILES_REPO" "$DOTFILES_DIR"
fi
"$DOTFILES_DIR/make_dotfiles.sh" -i
printf 'Bootstrap complete.\n'
