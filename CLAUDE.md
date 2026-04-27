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
| `postmake.sh` | Writes git identity to `~/.gitconfig.local` and restarts shell |

## Running the Scripts

```zsh
# Full install (packages + all dotfiles)
./make_dotfiles.sh -i

# Symlink all dotfiles only
./make_dotfiles.sh

# Symlink a single dotfile
./make_dotfiles.sh dotfiles/.zshrc

# Capture currently installed Homebrew packages into the Brewfile
./install_packages.sh --capture

# Update: pull latest then redeploy
git pull origin main && ./make_dotfiles.sh
```

## Architecture

- **`dotfiles/`** — files here are symlinked to `$HOME` by `make_dotfiles.sh`. Currently contains `.zshrc` and `.gitconfig`. Edits to `~/.<file>` are edits to the repo file directly.
- **`packages/Brewfile`** — single source of truth for all Homebrew packages (formulae and casks). Managed via `brew bundle`.
- **`misc_dotfiles/`** — reference configs not auto-deployed (e.g. `.docker/` settings for manual use).
- **`iterm_colors/`** — iTerm2 color schemes to be imported manually via iTerm2 preferences.

## Identity Preservation Pattern

`vars.sh` exports `DOTFILE_GITCONFIG_USER` and `DOTFILE_GITCONFIG_EMAIL` from the current git config before deployment. `postmake.sh` writes them to `~/.gitconfig.local` (not tracked in the repo). `dotfiles/.gitconfig` uses `[include] path = ~/.gitconfig.local` to pull in the identity — this keeps name/email out of the repo while still being applied globally.

On repeat runs, `postmake.sh` skips writing `~/.gitconfig.local` if it already exists. To change identity, edit that file directly.

## Adding/Removing Packages

Edit `packages/Brewfile` directly — use `brew "name"` for formulae and `cask "name"` for casks. To sync the Brewfile with what's currently installed on a machine: `./install_packages.sh --capture`.

## `.gitconfig` Aliases

The deployed `.gitconfig` defines several compound git aliases worth knowing when editing that file:

- `compom` = checkout default branch + pull
- `comb` = `compom` + create new branch
- `spomp` / `scomp` / `scomb` = stash-aware variants of the above
- `rim` = interactive rebase onto default branch
- `pushu` = push with `--set-upstream` to current branch
