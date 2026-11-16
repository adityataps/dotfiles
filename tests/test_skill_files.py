"""Check the intentionally small, portable SKILL.md metadata schema."""
from pathlib import Path
import re
import unittest

SKILLS = Path(__file__).resolve().parents[1] / "skills"


class SkillFileTests(unittest.TestCase):
    def test_requested_starter_skills_are_present(self):
        expected = {"prepare-pr", "review-changes", "handoff-work", "inspect-repo",
                    "conventional-commits", "us-english", "technical-documentation", "pr-lifecycle"}
        actual = {p.parent.name for p in SKILLS.glob("*/SKILL.md")}
        self.assertTrue(expected.issubset(actual), f"Missing skills: {expected - actual}")

    def test_portable_metadata_and_nonempty_body(self):
        for path in SKILLS.glob("*/SKILL.md"):
            with self.subTest(skill=path.parent.name):
                text = path.read_text()
                match = re.match(r"\A---\n(.*?)\n---\n(.+)\Z", text, re.S)
                self.assertIsNotNone(match, "Expected YAML frontmatter and a body")
                fields = {}
                for line in match.group(1).splitlines():
                    key, separator, value = line.partition(":")
                    self.assertTrue(separator)
                    self.assertNotIn(key, fields)
                    fields[key] = value.strip()
                self.assertEqual(set(fields), {"name", "description"})
                self.assertEqual(fields["name"], path.parent.name)
                self.assertRegex(fields["name"], r"^[a-z0-9]+(-[a-z0-9]+)*$")
                self.assertLessEqual(len(fields["name"]), 64)
                self.assertTrue(fields["description"].startswith("Use when "))
                self.assertLessEqual(len(fields["description"]), 1024)
                self.assertNotIn(": ", fields["description"])
                self.assertNotIn(" #", fields["description"])
                self.assertTrue(match.group(2).strip())


if __name__ == "__main__":
    unittest.main()
