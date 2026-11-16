---
name: conventional-commits
description: Use when creating or suggesting branch names, commit messages, pull request titles, or squash-merge titles.
---

# Conventional commits and branches

Describe the final change with a consistent type, optional scope, and concise imperative subject.

| Artifact | Format | Example |
| --- | --- | --- |
| Commit or PR title | `type(scope): subject` or `type: subject` | `fix(shell): quote editor arguments` |
| Branch | `type/lowercase-hyphenated-slug` | `fix/quote-editor-arguments` |
| Breaking change | `type(scope)!: subject` and an explanatory `BREAKING CHANGE:` footer | `feat(config)!: require an explicit profile` |

Use `feat` for new capability, `fix` for broken behavior, `docs` for documentation, `refactor` for behavior-preserving restructuring, `perf` for performance, `test` for tests, `ci` for CI, `build` for build/dependency tooling, `style` for formatting, `chore` for maintenance, and `revert` for reversions. Choose the type from the final diff, not just the task's original label. A useful scope names a component; omit an unhelpful scope.

Branch slugs contain lowercase ASCII letters, digits, and single hyphens between words. Use the same type as the principal change. Examples include `feat/linux-support`, `docs/configuration-guide`, and `ci/test-global-skills`. Branches use a slash after the type, never a colon, parentheses, spaces, or underscores. Avoid credentials and private details in every Git artifact.

## Workflow

1. Inspect the current branch, status, relevant diff, and repository instructions.
2. Choose the type and optional scope; describe what the change accomplishes in US English.
3. Use the convention when creating a new branch or commit. Preserve existing work and unrelated staged changes. Do not rewrite published commits or rename an existing branch solely to normalize its name unless the user requested that operation.
4. Keep the PR title and description aligned with the final implementation as scope evolves. Use the same title convention for a squash merge when merging is authorized.

For a proposed name, return the requested artifacts directly. For an executed operation, report the actual branch, commit, or PR URL. Writing a suggested message does not authorize a commit, push, history rewrite, or merge; act within the user's existing task authorization.

Reference: [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). The slash-separated branch format is a personal convention layered on top of the commit specification.
