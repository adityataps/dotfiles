#!/bin/bash
# Opt-in global skills for terminal Codex and Claude Code; macOS Bash 3.2/Linux.
set -euo pipefail
shopt -s nullglob
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source_root="$SCRIPT_DIR/skills"
agent=all
dry_run=0
names=()

usage() {
    cat <<USAGE
Usage: $0 [--agent codex|claude|all] [--dry-run] [skill ...]
Link selected skills globally (default: all repository skills, both agents).
  --source DIRECTORY  Use another reviewed skill collection
  -n, --dry-run       Preview without creating directories or links
  -h, --help          Show help
Existing skills are never overwritten. Normal dotfile setup does not run this.
USAGE
}
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        -n|--dry-run) dry_run=1 ;;
        --agent|--source)
            [[ $# -ge 2 && -n "$2" ]] || die "$1 requires a value."
            if [[ "$1" = --agent ]]; then agent="$2"; else source_root="$2"; fi
            shift
            ;;
        --) shift; names+=("$@"); break ;;
        -*) die "Unknown option: $1" ;;
        *) names+=("$1") ;;
    esac
    shift
done
case "$agent" in
    codex) roots=("$HOME/.agents/skills") ;;
    claude) roots=("$HOME/.claude/skills") ;;
    all) roots=("$HOME/.agents/skills" "$HOME/.claude/skills") ;;
    *) die "Unknown agent: $agent" ;;
esac
[[ -d "$source_root" ]] || die "Skill collection not found: $source_root"
source_root="$(cd "$source_root" && pwd -P)"
if [[ ${#names[@]} -eq 0 ]]; then
    for folder in "$source_root"/*; do
        [[ -d "$folder" && -f "$folder/SKILL.md" ]] || continue
        names+=("$(basename "$folder")")
    done
fi
[[ ${#names[@]} -gt 0 ]] || die "No skills found in $source_root"

# Preflight the entire selection and every agent root before making changes.
for name in "${names[@]}"; do
    [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "Invalid skill name: $name"
    case "$name" in synced|anthropic-skills) die "Reserved skill name: $name" ;; esac
    [[ -f "$source_root/$name/SKILL.md" && -r "$source_root/$name/SKILL.md" ]] || die "Missing readable SKILL.md for $name"
done
for root in "${roots[@]}"; do
    parent="$root"
    while [[ "$parent" != / ]]; do
        if [[ -e "$parent" || -L "$parent" ]]; then
            [[ -d "$parent" ]] || die "Not a directory: $parent"
        fi
        parent="$(dirname "$parent")"
    done
    for name in "${names[@]}"; do
        target="$root/$name"
        source_dir="$source_root/$name"
        if [[ -L "$target" && "$(readlink "$target")" = "$source_dir" ]]; then continue; fi
        [[ ! -e "$target" && ! -L "$target" ]] || die "Existing skill at $target; inspect it manually before choosing a new name or moving it."
    done
done

for root in "${roots[@]}"; do
    for name in "${names[@]}"; do
        target="$root/$name"
        source_dir="$source_root/$name"
        # Recheck in case both agent roots already point at the same directory.
        if [[ -L "$target" && "$(readlink "$target")" = "$source_dir" ]]; then
            printf 'Already linked: %s\n' "$target"
        elif [[ $dry_run -eq 1 ]]; then
            printf 'Would link %s -> %s\n' "$target" "$source_dir"
        else
            mkdir -p "$root"
            ln -s "$source_dir" "$target"
            printf 'Linked: %s -> %s\n' "$target" "$source_dir"
        fi
    done
done
printf 'Keep the checkout at this path. Start a new agent session to check discovery.\n'
