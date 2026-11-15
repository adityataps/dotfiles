# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Does

Personal dotfiles manager for macOS/oh-my-zsh. The scripts symlink config files from `dotfiles/` into `$HOME` and manage Homebrew packages via a `Brewfile`.

## Key Scripts

| Script | Purpose |
|---|---|
| `make_dotfiles.sh` | Main entry point — symlinks dotfiles into `$HOME` |
| `install_packages.sh` | Homebrew install/upgrade via `brew bundle` (macOS only) |
| `vars.sh` | Captures git identity before deployment (sourced by `make_dotfiles.sh`) |
| `postmake.sh` | Initializes `~/.gitconfig.local`; never launches a shell |

## Running the Scripts

```zsh
# Full install (packages + all dotfiles)
./make_dotfiles.sh -i

# Symlink all dotfiles only
./make_dotfiles.sh

# Preview without changes (also skips packages and identity prompts)
./make_dotfiles.sh --dry-run

# Symlink a single dotfile
./make_dotfiles.sh dotfiles/.zshrc

# Capture currently installed Homebrew packages into the Brewfile
./install_packages.sh --capture

# Update: pull latest then redeploy
git pull --ff-only origin main && ./make_dotfiles.sh

# Dependency-free regression checks (temporary homes/repos; no downloads)
python3 -m unittest discover -s tests -v
```

## Architecture

- **`dotfiles/`** — files here are symlinked to `$HOME` by `make_dotfiles.sh`. Currently contains `.zshrc` and `.gitconfig`. Edits to `~/.<file>` are edits to the repo file directly.
- **`packages/Brewfile`** — single source of truth for all Homebrew packages (formulae and casks). Managed via `brew bundle`.
- **`misc_dotfiles/`** — reference configs not auto-deployed (e.g. `.docker/` settings for manual use).
- **`iterm_colors/`** — iTerm2 color schemes to be imported manually via iTerm2 preferences.

## Identity Preservation Pattern

`vars.sh` captures global Git identity, including included files, before deployment. Repository-local identity must never become the global identity. For unattended setup, supply `DOTFILE_GITCONFIG_USER` and `DOTFILE_GITCONFIG_EMAIL`; missing identity fails before deployment. This runs only when deploying `.gitconfig`. `postmake.sh` writes values using `git config --file` so special characters are escaped correctly. The shared config includes `~/.gitconfig.local`.

On repeat runs, existing local identity and preferences are preserved. Missing identity fields are filled from captured global values. To change identity, edit that file directly.

## Adding/Removing Packages

Edit `packages/Brewfile` directly — use `brew "name"` for formulae and `cask "name"` for casks. To sync the Brewfile with what's currently installed on a machine: `./install_packages.sh --capture`.

Default installs use `brew bundle install --no-upgrade`. Use `./install_packages.sh --upgrade` for explicit Brewfile upgrades. Only bootstrap installs Homebrew itself; normal setup reports a missing dependency.

## Deployment Constraints

- Maintain compatibility with macOS `/bin/bash` 3.2; no associative arrays or GNU-only filesystem flags.
- Validate all source paths and destinations before mutation. Existing directories are rejected; replaced files and symlinks go to `${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/<unique-run>/`.
- Do not run setup against the real home during tests. Mock external package/network commands, but exercise real filesystem and Git operations.
- Full setup clones Oh My Zsh without running its installer, changing the login shell, or replacing shell config externally. Shell startup must work when optional tools are absent.

## `.gitconfig` Aliases

The deployed `.gitconfig` defines several compound git aliases worth knowing when editing that file:

- `compom` = checkout default branch + pull
- `comb` = `compom` + create new branch
- `spomp` / `scomp` / `scomb` = stash-aware variants of the above
- `rim` = interactive rebase onto default branch
- `pushu` = push with `--set-upstream` to current branch

Compound aliases stop on failure. Stash wrappers pop only their own new stash after success; failed operations leave it available for manual recovery. Default-branch aliases use local `origin/HEAD`; refresh it with `git remote set-head origin -a`.
