"""Exercise global skill linking with disposable homes; never install real skills."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SkillInstallTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="skill install ")
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name).resolve()
        self.home = self.base / "home"
        self.home.mkdir()
        self.source = self.base / "shared skills"
        for name in ("review-changes", "prepare-pr"):
            folder = self.source / name
            folder.mkdir(parents=True)
            (folder / "SKILL.md").write_text(f"---\nname: {name}\ndescription: Test fixture.\n---\n")
        self.env = dict(os.environ, HOME=str(self.home))

    def install(self, *args):
        return subprocess.run(["/bin/bash", str(ROOT / "install_skills.sh"), "--source", str(self.source), *args],
                              env=self.env, text=True, capture_output=True, timeout=10)

    def target(self, agent, name="review-changes"):
        return self.home / (".agents" if agent == "codex" else ".claude") / "skills" / name

    def test_help_does_not_write(self):
        result = self.install("--help")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_dry_run_does_not_write(self):
        result = self.install("--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(list(self.home.iterdir()), [])
        self.assertIn("Would link", result.stdout)

    def test_default_installs_both_agents_and_repeat_is_noop(self):
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        for agent in ("codex", "claude"):
            target = self.target(agent)
            self.assertTrue(target.is_symlink())
            self.assertEqual(target.resolve(), self.source / "review-changes")
        inode = self.target("codex").lstat().st_ino
        self.assertEqual(self.install().returncode, 0)
        self.assertEqual(self.target("codex").lstat().st_ino, inode)

    def test_agent_and_skill_selection(self):
        result = self.install("--agent", "claude", "review-changes")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.target("claude").is_symlink())
        self.assertFalse(self.target("codex").exists())
        self.assertFalse(self.target("claude", "prepare-pr").exists())

    def test_conflict_fails_before_any_links_are_created(self):
        existing = self.target("claude")
        existing.mkdir(parents=True)
        (existing / "SKILL.md").write_text("precious local skill\n")
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.target("codex").parent.exists())
        self.assertFalse(self.target("claude", "prepare-pr").exists())
        self.assertEqual((existing / "SKILL.md").read_text(), "precious local skill\n")

    def test_broken_link_is_not_overwritten(self):
        existing = self.target("codex")
        existing.parent.mkdir(parents=True)
        existing.symlink_to("/missing/old-skill")
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(os.readlink(existing), "/missing/old-skill")

    def test_non_directory_parent_is_rejected_before_other_agent_changes(self):
        (self.home / ".claude").write_text("keep")
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.home / ".agents").exists())

    def test_missing_skill_fails_before_linking_valid_selection(self):
        result = self.install("prepare-pr", "missing-skill")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_invalid_agent_fails_without_writes(self):
        self.assertNotEqual(self.install("--agent", "unknown").returncode, 0)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_shared_existing_root_directory_works_for_both_agents(self):
        shared = self.base / "existing root"
        shared.mkdir()
        for folder in (".agents", ".claude"):
            (self.home / folder).mkdir()
            (self.home / folder / "skills").symlink_to(shared)
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((shared / "review-changes").resolve(), self.source / "review-changes")


if __name__ == "__main__":
    unittest.main()
