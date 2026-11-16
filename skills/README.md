# Shared global agent skills

One reviewed source collection for local Codex and Claude Code sessions. Each skill uses standard `SKILL.md` frontmatter and tool-neutral instructions. No private installed skills, plugin caches, or account-synced content are copied into this repository.

| Skill | Trigger and result |
| --- | --- |
| `prepare-pr` | Prepare accurate, proportional PR metadata from the final diff and actual verification. |
| `review-changes` | Review changes for concrete regressions and report evidence-based findings first. |
| `handoff-work` | Transfer task state, decisions, verification freshness, blockers, and next actions. |
| `inspect-repo` | Establish architecture, entry points, constraints, and documented checks before changing an unfamiliar repo. |
| `conventional-commits` | Use `type(scope): subject` for commits/PR titles and `type/lowercase-hyphenated-slug` for new branches. |
| `us-english` | Use US English in authored prose while preserving identifiers, quotations, interfaces, and locale-specific facts. |
| `technical-documentation` | Write Google-style developer docs with prerequisites, actionable steps, verification, and unwrapped prose paragraphs. |
| `pr-lifecycle` | Create drafts first, self-review and verify current HEAD, then mark ready when completing the workflow is in scope. |

## Install locally

From your stable dotfiles checkout:

```sh
./install_skills.sh --dry-run
./install_skills.sh
```

To install a subset or only one agent:

```sh
./install_skills.sh --agent codex conventional-commits review-changes
./install_skills.sh --agent claude technical-documentation us-english
```

| Agent | Global discovery path |
| --- | --- |
| Codex | `~/.agents/skills/<name>/SKILL.md` |
| Claude Code | `~/.claude/skills/<name>/SKILL.md` |

The installer links individual skill directories rather than replacing either root. Existing correct links are left alone. Any conflicting file, directory, or broken symlink stops preflight before links are written. There is no force/overwrite option. Inspect and manually move an existing conflicting skill, or choose a new skill name. Plugin-managed and `synced` folders remain untouched. `--source DIRECTORY` selects another collection you have reviewed.

Installation is opt-in: neither `make_dotfiles.sh` nor package/bootstrap setup invokes it. The installer works with macOS Bash 3.2 and Linux without Homebrew or Stow. It does not change your active agent session or install agent executables.

## Update, discover, and remove

Keep the checkout at its installed path. Editing or pulling the source updates the linked files; start a new agent session to confirm discovery. If you move the checkout, inspect the old links and relink them explicitly. The installer deliberately treats stale links as conflicts.

To remove one installed link, confirm its target first, then unlink it. For example:

```sh
readlink "$HOME/.agents/skills/conventional-commits"
unlink "$HOME/.agents/skills/conventional-commits"
```

This removes the link, not its source skill. Remove the corresponding Claude link separately if desired. Do not remove a whole skills root or a directory containing unrelated skills.

## Behavior and scope

Agents load applicable skill instructions on demand; these files do not guarantee that every skill is active on every turn. Put truly unconditional preferences in the relevant agent's global instructions if you also need them always loaded. Repository/user instructions and task authorization still apply. Skills do not grant access to tools, credentials, merges, or external systems.

The same instruction sources work across local agents, but tools, permissions, invocation UI, and discovery behavior can differ. These symlinks do not upload skills to ChatGPT, write GPT memory, or enable skills in Claude Cowork/cloud sessions. Use each product's account-level installation mechanism for those environments. Existing plugins and installed skills remain separate; avoid deliberately installing overlapping workflows under conflicting names.

New PRs start draft. A completed, authorized PR workflow can become ready after current-head self-review and required verification. Draft-only requests stay draft; marking ready never means merge or independent approval.

Documentation prose stays on one physical line per paragraph. Blank lines, headings, list items, tables, and meaningful code/output newlines remain intact. The US English skill does not rename a flag such as `--colour` or convert a British customer's currency or dates.

## Verify changes

Run `python3 -m unittest discover -s tests -v` from the repo root. Automated checks cover metadata and installation safety in disposable homes. [Behavior scenarios](../tests/skill_scenarios.md) exercise the instructions themselves; schema validation alone does not prove an agent follows them. Recheck changed skills with fresh scenarios before publication.

References: [Codex skills](https://developers.openai.com/codex/skills/), [Claude Code skills](https://code.claude.com/docs/en/skills), [Agent Skills specification](https://agentskills.io/specification), [Google developer documentation style](https://developers.google.com/style/highlights), and [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).
