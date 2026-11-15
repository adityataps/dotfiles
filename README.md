# dotfiles

Personal macOS development setup: Zsh with the Bureau theme, Git aliases, and Homebrew packages. Works with Apple Silicon and Intel Homebrew installations.

## Install

On an existing Mac with Git and Homebrew:

```sh
git clone https://github.com/adityataps/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./make_dotfiles.sh --dry-run
./make_dotfiles.sh -i
```

For a fresh Mac, download and review the bootstrap script, then run it:

```sh
curl -fsSLo bootstrap.sh https://raw.githubusercontent.com/adityataps/dotfiles/main/bootstrap.sh
less bootstrap.sh
/bin/bash bootstrap.sh
```

Bootstrap installs Homebrew if needed, clones into `~/.dotfiles`, and runs full setup. If Command Line Tools are missing, finish Apple's installer and rerun bootstrap. Override the checkout location with `DOTFILES_DIR=/your/path`. Existing checkouts must have the expected origin, be clean, and be on `main`; updates are fast-forward only.

Full setup (`-i`) installs missing Brewfile packages and clones Oh My Zsh. It does not change the login shell or launch a new shell. Open a new terminal afterward, or run `exec zsh` yourself.

## Deploy and update

```sh
./make_dotfiles.sh --dry-run            # preview; no writes, prompts, or installs
./make_dotfiles.sh                      # link all configs, without package operations
./make_dotfiles.sh dotfiles/.zshrc       # deploy just one file
./make_dotfiles.sh -i dotfiles/.zshrc    # packages first, then the selected file

git pull --ff-only origin main
./make_dotfiles.sh
```

Run from the checkout, or invoke the script by absolute path from anywhere. Quote paths containing spaces. Unknown options, missing sources, duplicate destinations, and existing directories fail before deployment.

Files in `dotfiles/` are symlinked directly into `$HOME`. Editing a deployed `~/.zshrc` or `~/.gitconfig` edits the repository file.

## Backups and recovery

Existing files and symlinks (including broken symlinks) are moved into a unique directory under `${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/` before replacement. The installer prints that directory. Already-correct links are left alone; rerunning does not create redundant backups.

To restore a config, remove its deployed symlink and move its backup back into place. For example, after substituting the directory printed during installation:

```sh
unlink "$HOME/.zshrc"
mv "$HOME/.local/state/dotfiles/backups/<run>/.zshrc" "$HOME/.zshrc"
```

Backups may contain private settings; keep them on the machine. Deployment stops on errors but is not a transaction: if a later filesystem operation fails, earlier links remain applied and replaced files remain in the printed backup directory.

## Machine-specific settings

- Shell aliases, virtualenv paths, and private environment variables: `~/.zshrc.local`. See [the example](examples/zshrc.example); it is not deployed automatically.
- Git identity and local preferences: `~/.gitconfig.local`. Setup captures the existing **global** name/email before replacing `.gitconfig`, ignoring repository-local identity. Existing local identity and preferences are preserved; missing identity fields are filled from the captured values.

For unattended setup with no existing Git identity:

```sh
DOTFILE_GITCONFIG_USER='Your Name' \
DOTFILE_GITCONFIG_EMAIL='you@example.com' \
./make_dotfiles.sh
```

Interactive setup prompts for missing identity. Noninteractive setup reports missing values before linking anything. Deploying only `.zshrc` needs no Git identity.

Zsh starts even without Oh My Zsh, nvm, or Cargo. The nvm loader supports both `~/.nvm/nvm.sh` and an existing Homebrew installation. Node versions still need to be installed separately (`nvm install --lts`). Machine-specific paths such as the old `env-dbt` alias belong in `.zshrc.local`.

## Packages

Edit [packages/Brewfile](packages/Brewfile) to manage packages.

```sh
./install_packages.sh             # install missing declared packages; no blanket upgrade
./install_packages.sh --upgrade   # explicitly upgrade Brewfile packages
./install_packages.sh --capture   # replace Brewfile with this machine's installed packages
```

Review captures before committing, especially when sharing the repo across your MacBook Pro and Mac Studio. Regular setup requires Homebrew to be installed; bootstrap handles installing it. Existing apps are not automatically adopted, and package setup does not run `brew cleanup`.

The `brewup` shell alias remains an explicit full Homebrew upgrade and cleanup.

## Git shortcuts

| Alias | Action |
| --- | --- |
| `compom` | Checkout the default branch and pull with rebase |
| `comb <branch>` | Update the default branch, then create a branch |
| `spomp`, `scomp`, `scomb <branch>` | Stash tracked changes around `pom`, `compom`, or `comb` |
| `pushu` | Push the current branch with upstream tracking |
| `rim` | Interactive rebase onto the default branch |

Default-branch shortcuts use local `origin/HEAD` metadata. If missing or outdated, run `git remote set-head origin -a`. Compound commands stop on failure. Stash wrappers restore only their own new stash after success; failures or a changed stash stack leave it available for manual recovery. Untracked files retain Git's default stash behavior and are not stashed.

## Checks

```sh
python3 -m unittest discover -s tests -v
for script in *.sh; do /bin/bash -n "$script"; done
zsh -n dotfiles/.zshrc
shellcheck -x *.sh  # optional local tool; installed by CI
```

Tests use disposable homes and real temporary Git repositories. Package/network calls are replaced with test doubles, so checks do not install software or modify your active dotfiles. GitHub Actions runs the checks on macOS and Linux. The scripts target macOS's Bash 3.2; package setup and bootstrap require macOS.

`misc_dotfiles/` contains reference configurations for manual use. Import `iterm_colors/Elementary.itermcolors` through iTerm2 preferences.

## License

[MIT](LICENSE.md)
