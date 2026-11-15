#!/bin/bash
# Deploy from any working directory; compatible with macOS Bash 3.2.
set -euo pipefail
shopt -s dotglob nullglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
dry_run=0
install_packages=0
deploy_gitconfig=0
sources=()
backup_dir=""

usage() {
    cat <<USAGE
Usage: $0 [options] [file ...]
Without files, deploy everything in dotfiles/.
  -i, --install-packages  Install missing Homebrew packages and Oh My Zsh first
  -n, --dry-run           Preview without writing files or installing anything
  -h, --help              Show this help
Existing files and symlinks are backed up before replacement.
USAGE
}

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        -i|--install-packages) install_packages=1 ;;
        -n|--dry-run) dry_run=1 ;;
        --) shift; sources+=("$@"); break ;;
        -*) die "Unknown option: $1 (see --help)" ;;
        *) sources+=("$1") ;;
    esac
    shift
done

# Personal banner, kept as readable text rather than an encoded blob.
cat <<'BANNER'
       ,,                    ,...,,    ,,
     `7MM           mm     .d' ""db  `7MM
       MM           MM     dM`         MM
  ,M""bMM  ,pW"Wq.mmMMmm  mMMmm`7MM    MM  .gP"Ya  ,pP"Ybd
,AP    MM 6W'   `Wb MM     MM    MM    MM ,M'   Yb 8I   `"
8MI    MM 8M     M8 MM     MM    MM    MM 8M"""""" `YMMMa.
`Mb    MM YA.   ,A9 MM     MM    MM    MM YM.    , L.   I8
 `Wbmd"MML.`Ybmd9'  `Mbmo.JMML..JMML..JMML.`Mbmmd' M9mmmP'
BANNER

if [[ ${#sources[@]} -eq 0 ]]; then
    sources=("$SCRIPT_DIR"/dotfiles/*)
fi
[[ ${#sources[@]} -gt 0 ]] || die "No dotfiles found."

# Validate the entire selection before installing packages or changing files.
targets=()
for index in "${!sources[@]}"; do
    source_file="${sources[$index]}"
    [[ -f "$source_file" && -r "$source_file" ]] || die "Not a readable file: $source_file"
    source_file="$(cd "$(dirname "$source_file")" && pwd -P)/$(basename "$source_file")"
    sources[index]="$source_file"
    target="$HOME/$(basename "$source_file")"
    [[ "$source_file" != "$target" ]] || die "Source is already at its destination: $target"
    [[ ! -d "$target" ]] || die "Refusing to replace a directory: $target"
    for previous in "${targets[@]+"${targets[@]}"}"; do
        [[ "$target" != "$previous" ]] || die "Duplicate destination: $target"
    done
    targets+=("$target")
    [[ "$(basename "$source_file")" != .gitconfig ]] || deploy_gitconfig=1
done

# A source symlink must not depend on a destination that will be replaced.
# Validate across the whole selection before backing up any destination.
for source_file in "${sources[@]}"; do
    [[ -L "$source_file" ]] || continue
    for index in "${!targets[@]}"; do
        target="${targets[$index]}"
        if [[ -L "$target" && "$(readlink "$target")" = "${sources[$index]}" ]]; then
            continue  # This destination is already correct and will not change.
        fi
        [[ ! "$source_file" -ef "$target" ]] || die "Source depends on a destination being replaced: $source_file -> $target"
    done
done

if [[ $dry_run -eq 1 ]]; then
    [[ $install_packages -eq 0 ]] || printf 'Would install missing Homebrew packages and Oh My Zsh.\n'
    for index in "${!sources[@]}"; do
        printf 'Would link %s -> %s (backing up any existing target).\n' "${targets[$index]}" "${sources[$index]}"
    done
    exit 0
fi

# Capture global identity before replacing .gitconfig, never repository overrides.
if [[ $deploy_gitconfig -eq 1 ]]; then
    # shellcheck source=vars.sh
    source "$SCRIPT_DIR/vars.sh"
fi

if [[ $install_packages -eq 1 ]]; then
    "$SCRIPT_DIR/install_packages.sh"
    zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
    if [[ ! -f "$zsh_dir/oh-my-zsh.sh" ]]; then
        [[ ! -e "$zsh_dir" && ! -L "$zsh_dir" ]] || die "Incomplete Oh My Zsh installation: $zsh_dir"
        # Clone only: do not replace .zshrc, change the login shell, or launch zsh.
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
    fi
fi

if [[ $deploy_gitconfig -eq 1 ]]; then
    "$SCRIPT_DIR/postmake.sh"
fi

for index in "${!sources[@]}"; do
    source_file="${sources[$index]}"
    target="${targets[$index]}"
    if [[ -L "$target" && "$(readlink "$target")" = "$source_file" ]]; then
        printf 'Already linked: %s\n' "$target"
        continue
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -z "$backup_dir" ]]; then
            backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups"
            mkdir -p "$backup_root"
            backup_dir="$(mktemp -d "$backup_root/$(date +%Y%m%d-%H%M%S).XXXXXX")"
        fi
        mv "$target" "$backup_dir/"
        printf 'Backed up: %s -> %s/\n' "$target" "$backup_dir"
    fi
    ln -s "$source_file" "$target"
    printf 'Linked: %s -> %s\n' "$target" "$source_file"
done

printf 'Done. Open a new terminal or run: exec zsh\n'
