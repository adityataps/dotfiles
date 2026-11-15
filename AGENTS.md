# Repository guide

Personal macOS dotfiles for Zsh/Oh My Zsh, Git, and Homebrew. Keep this repo small and understandable; preserve its aliases, Bureau theme, and ASCII banner when making maintenance changes.

## Layout and entry points

- `make_dotfiles.sh`: validates selected files, optionally installs packages/Oh My Zsh, captures Git identity, and symlinks `dotfiles/` into `$HOME`.
- `bootstrap.sh`: fresh-Mac prerequisites and checkout; delegates deployment to `make_dotfiles.sh -i`.
- `vars.sh`: sourced before replacing `.gitconfig`; captures global/local identity without repository overrides.
- `postmake.sh`: initializes or fills missing identity fields in `~/.gitconfig.local`; preserves existing settings.
- `install_packages.sh`: installs missing Brewfile packages; `--upgrade` explicitly upgrades, `--capture` replaces the manifest.
- `dotfiles/.zshrc` and `dotfiles/.gitconfig`: deployed configs. Editing a deployed symlink can edit this checkout directly.
- `packages/Brewfile`: package manifest; retain the user's package choices.
- `tests/test_dotfiles.py`: standard-library integration tests using disposable homes and real Git repositories.
- `.github/workflows/check.yaml`: macOS/Linux CI with ShellCheck, syntax checks, and regression tests.
- `examples/`, `misc_dotfiles/`, `iterm_colors/`: manual references; never automatically deploy them.

## Verification

Run from the repository root:

```sh
python3 -m unittest discover -s tests -v
for script in *.sh; do /bin/bash -n "$script" || exit; done
zsh -n dotfiles/.zshrc
shellcheck -x *.sh
git diff --check
```

Python 3 and Zsh are needed for tests. ShellCheck is an optional local dependency and is installed by CI. There is no application build or dependency installation step for the test suite.

Use `./make_dotfiles.sh --dry-run` to inspect deployment. Do not run real installers or source the shared shell config against the user's active home as a test. Mock package/network commands in tests; keep filesystem and Git behavior real.

## Implementation constraints

- Support macOS `/bin/bash` 3.2: no associative arrays, `mapfile`, GNU-only flags, or dependencies on newer Bash syntax.
- Quote paths and handle spaces. Validate every selected source and destination before changing files or installing software.
- Keep dry runs free of writes, identity prompts, and package operations. Help should exit successfully without mutations.
- Back up replaced files and symlinks under `${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/`; reject directory destinations. Correct existing links should be a no-op.
- Preserve global Git identity, including included config. Never promote repository-local identity to global settings. Use `git config --file` rather than writing unescaped values.
- Keep personal shell settings/secrets in `~/.zshrc.local` and Git settings in `~/.gitconfig.local`; never commit credentials, machine paths, or backups.
- Do not launch a new shell, change the login shell, or perform blanket package upgrades during normal setup.
- Guard optional shell tools and keep PATH stable across reloads. Package/bootstrap scripts target macOS; tests also run on Linux.
- Compound Git aliases must stop on failure. Stash wrappers must preserve recoverable work and must not pop another operation's stash.
- Use `.yaml` for YAML files. Keep IDE-generated `.idea/` and `*.iml` files untracked unless a specific shared setting is intentionally selected.

## Scope

Keep global agent-skill installation and deployment out of this cleanup PR. Add those in a separate PR after this one is verified. Update this guide when entry points, safety guarantees, or verification commands change.
