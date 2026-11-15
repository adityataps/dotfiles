"""Run real installers and Git aliases against disposable homes/repositories."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
GIT = shutil.which("git")


class DotfilesFixture(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="dotfiles tests ")
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name).resolve()
        self.home = self.base / "home"
        self.home.mkdir()
        self.bin = self.base / "bin"
        self.bin.mkdir()
        self.env = {k: v for k, v in os.environ.items()
                    if not k.startswith(("GIT_", "DOTFILE_", "HOMEBREW_", "XDG_"))
                    and k not in {"GOPATH", "PNPM_HOME", "NVM_DIR", "ZSH", "ZDOTDIR"}}
        self.env.update(HOME=str(self.home), SHELL=shutil.which("true"),
                        PATH=f"{self.bin}:/usr/bin:/bin:/usr/sbin:/sbin",
                        GIT_CONFIG_NOSYSTEM="1", XDG_CONFIG_HOME=str(self.home / ".config"))
        (self.bin / "git").symlink_to(GIT)
        # Prevent accidental networking or package operations in any regression.
        self.fake("curl", 'echo "unexpected network access" >&2; exit 97')
        self.fake("brew", 'echo "unexpected package operation" >&2; exit 97')
        self.fake("uname", 'echo Darwin')
        self.fake("xcode-select", 'exit 0')
        self.git("config", "--global", "user.name", 'Test "User" #1')
        self.git("config", "--global", "user.email", "test@example.invalid")

    def run_cmd(self, *args, cwd=None):
        return subprocess.run(args, cwd=cwd or self.base, env=self.env, input="",
                              text=True, capture_output=True, timeout=15)

    def git(self, *args, cwd=None):
        result = self.run_cmd(GIT, *args, cwd=cwd)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def script(self, name, *args, cwd=None):
        return self.run_cmd("/bin/bash", str(ROOT / name), *args, cwd=cwd)

    def fake(self, name, body):
        path = self.bin / name
        if path.is_symlink():
            path.unlink()
        path.write_text("#!/bin/bash\n" + body + "\n")
        path.chmod(0o755)

    def source(self, name=".custom config"):
        path = self.base / name
        path.write_text("new config\n")
        return path


class DotfilesTests(DotfilesFixture):
    def test_help_succeeds_without_changing_home(self):
        before = (self.home / ".gitconfig").read_bytes()
        result = self.script("make_dotfiles.sh", "--help")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(list(self.home.iterdir()), [self.home / ".gitconfig"])
        self.assertEqual((self.home / ".gitconfig").read_bytes(), before)

    def test_existing_file_is_backed_up_and_repeat_run_is_noop(self):
        target = self.home / ".zshrc"
        target.write_text("precious existing config\n")
        result = self.script("make_dotfiles.sh", str(ROOT / "dotfiles/.zshrc"))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(target.is_symlink())
        backups = list((self.home / ".local/state/dotfiles/backups").rglob(".zshrc"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "precious existing config\n")
        result = self.script("make_dotfiles.sh", str(ROOT / "dotfiles/.zshrc"))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(list((self.home / ".local/state/dotfiles/backups").rglob(".zshrc")), backups)

    def test_dry_run_changes_nothing(self):
        result = self.script("make_dotfiles.sh", "--dry-run", "-i")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.home / ".zshrc").exists())
        self.assertFalse((self.home / ".gitconfig.local").exists())
        self.assertFalse((self.home / ".local").exists())
        self.assertIn("Would", result.stdout)

    def test_missing_source_fails_before_any_deployment(self):
        path = self.source(".valid")
        result = self.script("make_dotfiles.sh", str(path), str(self.base / "missing"))
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.home / path.name).exists())

    def test_directory_target_is_rejected(self):
        path = self.source(".custom")
        target = self.home / path.name
        target.mkdir()
        result = self.script("make_dotfiles.sh", str(path))
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(target.iterdir()), [])

    def test_source_path_with_spaces(self):
        path = self.source()
        result = self.script("make_dotfiles.sh", str(path))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.home / path.name).resolve(), path)

    def test_failed_package_install_does_not_deploy(self):
        result = self.script("make_dotfiles.sh", "-i", str(ROOT / "dotfiles/.zshrc"))
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.home / ".zshrc").exists())

    def test_preserves_global_identity_instead_of_repository_identity(self):
        repo = self.base / "repository"
        repo.mkdir()
        self.git("init", "-q", cwd=repo)
        self.git("config", "user.name", "Wrong Repository Identity", cwd=repo)
        self.git("config", "user.email", "wrong@example.invalid", cwd=repo)
        result = self.script("make_dotfiles.sh", cwd=repo)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("config", "--get", "user.name"), 'Test "User" #1')
        self.assertEqual(self.git("config", "--get", "user.email"), "test@example.invalid")

    def test_noninteractive_missing_identity_fails_before_linking(self):
        (self.home / ".gitconfig").unlink()
        result = self.script("make_dotfiles.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.home / ".gitconfig").exists())
        self.assertFalse((self.home / ".zshrc").exists())

    def test_shell_only_deployment_needs_no_git_identity(self):
        (self.home / ".gitconfig").unlink()
        result = self.script("make_dotfiles.sh", str(ROOT / "dotfiles/.zshrc"))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.home / ".gitconfig.local").exists())

    def test_postmake_does_not_launch_shell_or_overwrite_local_settings(self):
        local = self.home / ".gitconfig.local"
        local.write_text('[credential]\n\thelper = custom-helper\n')
        shell_log = self.base / "shell-launched"
        self.fake("unexpected-shell", f'touch "{shell_log}"')
        self.env["SHELL"] = str(self.bin / "unexpected-shell")
        result = self.script("postmake.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(shell_log.exists())
        self.assertEqual(self.git("config", "--file", str(local), "credential.helper"), "custom-helper")

    def test_package_install_only_installs_missing_declared_packages(self):
        log = self.base / "brew-calls"
        self.fake("brew", f'printf "%s\\n" "$*" >> "{log}"')
        result = self.script("install_packages.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = log.read_text().splitlines()
        self.assertEqual(calls, [f"bundle install --no-upgrade --file={ROOT}/packages/Brewfile"])

    def test_package_failure_is_reported(self):
        result = self.script("install_packages.sh")
        self.assertNotEqual(result.returncode, 0)

    def test_package_upgrade_is_explicit_and_scoped_to_brewfile(self):
        log = self.base / "brew-calls"
        self.fake("brew", f'printf "%s\\n" "$*" >> "{log}"')
        result = self.script("install_packages.sh", "--upgrade")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(log.read_text().splitlines(), ["update", f"bundle upgrade --file={ROOT}/packages/Brewfile"])

    def test_full_install_installs_oh_my_zsh_before_deployment(self):
        self.fake("brew", "exit 0")
        self.fake("git", f'''if [[ "$1" == clone ]]; then
            target="${{@: -1}}"
            [[ ! -e "$HOME/.zshrc" ]] || exit 8
            mkdir -p "$target"
            touch "$target/oh-my-zsh.sh"
        else
            exec "{GIT}" "$@"
        fi''')
        result = self.script("make_dotfiles.sh", "-i", str(ROOT / "dotfiles/.zshrc"))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.home / ".oh-my-zsh/oh-my-zsh.sh").is_file())
        self.assertTrue((self.home / ".zshrc").is_symlink())

    def test_capture_does_not_hide_brew_failure(self):
        result = self.script("install_packages.sh", "--capture")
        self.assertNotEqual(result.returncode, 0)

    def test_identity_is_read_from_global_include(self):
        included = self.home / "identity"
        self.git("config", "--file", str(included), "user.name", "Included User")
        self.git("config", "--file", str(included), "user.email", "included@example.invalid")
        (self.home / ".gitconfig").write_text(f'[include]\n\tpath = "{included}"\n')
        result = self.script("make_dotfiles.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("config", "--get", "user.name"), "Included User")

    def test_existing_local_preferences_do_not_prevent_identity_preservation(self):
        local = self.home / ".gitconfig.local"
        local.write_text('[credential]\n\thelper = custom-helper\n')
        result = self.script("make_dotfiles.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("config", "--get", "user.name"), 'Test "User" #1')
        self.assertEqual(self.git("config", "--get", "user.email"), "test@example.invalid")
        self.assertEqual(self.git("config", "--file", str(local), "credential.helper"), "custom-helper")

    def test_existing_local_identity_is_preserved(self):
        local = self.home / ".gitconfig.local"
        self.git("config", "--file", str(local), "user.name", "Local User")
        self.git("config", "--file", str(local), "user.email", "local@example.invalid")
        result = self.script("make_dotfiles.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("config", "--get", "user.name"), "Local User")

    def test_bootstrap_rejects_dirty_existing_checkout(self):
        destination = self.home / ".dotfiles"
        destination.mkdir()
        self.git("init", "-q", "-b", "main", cwd=destination)
        self.git("remote", "add", "origin", "https://github.com/adityataps/dotfiles.git", cwd=destination)
        (destination / "uncommitted").write_text("keep")
        result = self.script("bootstrap.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("clean", result.stderr)
        self.assertNotIn("unexpected package operation", result.stderr)

    def test_zsh_starts_without_optional_tools_and_reload_deduplicates_path(self):
        zsh = shutil.which("zsh")
        self.assertIsNotNone(zsh)
        self.env["ZSH"] = str(self.home / "missing-oh-my-zsh")
        self.env["HOMEBREW_PREFIX"] = str(self.base / "missing-brew")
        local = self.home / ".zshrc.local"
        local.write_text("export DOTFILES_LOCAL_LOADED=yes\n")
        result = self.run_cmd(zsh, "-dfc", 'source "$1"; source "$1"; print -r -- "$DOTFILES_LOCAL_LOADED"; print -l -- $path', "test", str(ROOT / "dotfiles/.zshrc"))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        lines = result.stdout.splitlines()
        self.assertEqual(lines[0], "yes")
        self.assertEqual(lines.count(str(self.home / "go/bin")), 1, lines)

    def test_bootstrap_rejects_non_macos_before_network_access(self):
        self.fake("uname", "echo Linux")
        result = self.script("bootstrap.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected network access", result.stderr)
        self.assertIn("macOS", result.stderr)

    def test_bootstrap_rejects_unrelated_existing_directory(self):
        destination = self.home / ".dotfiles"
        destination.mkdir()
        (destination / "precious").write_text("keep")
        result = self.script("bootstrap.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("existing", result.stderr.lower())
        self.assertEqual((destination / "precious").read_text(), "keep")

    def test_broken_symlink_is_preserved_in_backup(self):
        path = self.source(".custom")
        target = self.home / path.name
        target.symlink_to("/nonexistent/original-config")
        result = self.script("make_dotfiles.sh", str(path))
        self.assertEqual(result.returncode, 0, result.stderr)
        backups = list((self.home / ".local/state/dotfiles/backups").rglob(".custom"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(os.readlink(backups[0]), "/nonexistent/original-config")

    def test_duplicate_destination_fails_before_deployment(self):
        path = self.source(".custom")
        other = self.base / "other"
        other.mkdir()
        second = other / ".custom"
        second.write_text("different")
        result = self.script("make_dotfiles.sh", str(path), str(second))
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.home / ".custom").exists())


class GitAliasTests(DotfilesFixture):
    def setUp(self):
        super().setUp()
        self.repo = self.base / "work"
        self.repo.mkdir()
        self.git("init", "-q", "-b", "main", cwd=self.repo)
        self.git("config", "include.path", str(ROOT / "dotfiles/.gitconfig"), cwd=self.repo)
        (self.repo / "tracked").write_text("base\n")
        self.git("add", "tracked", cwd=self.repo)
        self.git("commit", "-qm", "initial", cwd=self.repo)

    def test_compom_does_not_pull_if_checkout_fails(self):
        self.git("config", "alias.com", "!exit 9", cwd=self.repo)
        self.git("config", "alias.pom", "!touch should-not-exist", cwd=self.repo)
        result = self.run_cmd(GIT, "compom", cwd=self.repo)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.repo / "should-not-exist").exists())

    def test_stash_alias_does_not_pop_an_older_stash_when_tree_is_clean(self):
        (self.repo / "tracked").write_text("older stash\n")
        self.git("stash", "push", "-qm", "old", cwd=self.repo)
        old = self.git("rev-parse", "refs/stash", cwd=self.repo)
        self.git("config", "alias.pom", "!true", cwd=self.repo)
        result = self.run_cmd(GIT, "spomp", cwd=self.repo)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("rev-parse", "refs/stash", cwd=self.repo), old)
        self.assertEqual((self.repo / "tracked").read_text(), "base\n")

    def test_stash_alias_retains_changes_when_command_fails(self):
        (self.repo / "tracked").write_text("unsaved work\n")
        self.git("config", "alias.pom", "!exit 9", cwd=self.repo)
        result = self.run_cmd(GIT, "spomp", cwd=self.repo)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unsaved work", self.git("show", "stash:tracked", cwd=self.repo))

    def test_stash_alias_restores_its_changes_and_keeps_older_stash(self):
        (self.repo / "tracked").write_text("older stash\n")
        self.git("stash", "push", "-qm", "old", cwd=self.repo)
        old = self.git("rev-parse", "refs/stash", cwd=self.repo)
        (self.repo / "tracked").write_text("current work\n")
        self.git("config", "alias.pom", "!true", cwd=self.repo)
        result = self.run_cmd(GIT, "spomp", cwd=self.repo)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.repo / "tracked").read_text(), "current work\n")
        self.assertEqual(self.git("rev-parse", "refs/stash", cwd=self.repo), old)

    def test_getdef_uses_local_origin_head(self):
        self.git("update-ref", "refs/remotes/origin/trunk", "HEAD", cwd=self.repo)
        self.git("symbolic-ref", "refs/remotes/origin/HEAD", "refs/remotes/origin/trunk", cwd=self.repo)
        self.assertEqual(self.git("getdef", cwd=self.repo), "trunk")

    def test_getcurr_rejects_detached_head(self):
        self.git("checkout", "--detach", "-q", cwd=self.repo)
        result = self.run_cmd(GIT, "getcurr", cwd=self.repo)
        self.assertNotEqual(result.returncode, 0)

    def test_stash_alias_leaves_both_stashes_if_command_creates_another(self):
        (self.repo / "tracked").write_text("user work\n")
        self.git("config", "alias.pom", "!echo hook-work > tracked && git stash push -qm hook", cwd=self.repo)
        result = self.run_cmd(GIT, "spomp", cwd=self.repo)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.repo / "tracked").read_text(), "base\n")
        self.assertEqual(self.git("show", "stash@{0}:tracked", cwd=self.repo), "hook-work")
        self.assertEqual(self.git("show", "stash@{1}:tracked", cwd=self.repo), "user work")

    def test_scomb_forwards_branch_name_and_restores_work(self):
        (self.repo / "tracked").write_text("current work\n")
        self.git("config", "alias.compom", "!true", cwd=self.repo)
        result = self.run_cmd(GIT, "scomb", "feature/test", cwd=self.repo)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("branch", "--show-current", cwd=self.repo), "feature/test")
        self.assertEqual((self.repo / "tracked").read_text(), "current work\n")
        self.assertEqual(self.git("stash", "list", cwd=self.repo), "")

    def test_stash_is_retained_when_restoration_conflicts(self):
        (self.repo / "tracked").write_text("user work\n")
        self.git("config", "alias.pom", "!echo command-work > tracked", cwd=self.repo)
        result = self.run_cmd(GIT, "spomp", cwd=self.repo)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.git("show", "stash:tracked", cwd=self.repo), "user work")
        self.assertEqual((self.repo / "tracked").read_text(), "command-work\n")


if __name__ == "__main__":
    unittest.main()
