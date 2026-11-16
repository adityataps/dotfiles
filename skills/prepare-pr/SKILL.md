---
name: prepare-pr
description: Use when preparing a pull request description or title, organizing a branch for publication, or updating PR metadata after implementation scope changes.
---

# Prepare a pull request

Present the final change so a reviewer can assess the problem, resulting behavior, evidence, and trade-offs without reading the conversation.

## Preparation

1. Establish the target repository/base, current branch/head, working-tree status, task scope, and whether a PR already exists. Read repository instructions and templates. Preserve unrelated work.
2. Review the actual diff. Confirm the branch contains the intended files, with no credentials, generated noise, or accidental changes. Explain the final implementation rather than abandoned approaches or conversational history.
3. Use Conventional Commit syntax for commits and the PR title, and `type/lowercase-hyphenated-slug` for a new branch. The `conventional-commits` skill has the detailed naming convention when available.
4. Gather the checks actually run and the revision they cover. Distinguish passing, failing, pending, skipped, and unavailable validation. Do not infer a fresh result from stale evidence.

## PR description

Lead with the concrete problem and resulting behavior. For a small change, one or two sentences plus verification may be enough. For a larger change, add a short summary of the important components, meaningful trade-offs, validation, and material limitations. Use the repository template where present and scale detail to the diff. A before/after example helps when it makes the behavior easier to assess.

Write in US English. Keep Markdown prose paragraphs on single physical lines while preserving structural line breaks. Use descriptive file references when they help, not a dump of every changed filename. State untested behavior honestly.

## Publication

A request to suggest a title/body returns a draft of that text; it does not authorize staging, committing, pushing, or opening a PR. For an authorized publication task, create the PR as a draft first or update the existing PR. Apply the `pr-lifecycle` workflow when available: self-review the actual current head, resolve blockers, verify required checks, then mark ready only when completing the workflow is in scope. A draft-only request stays draft. Do not merge unless the user requested merging.

After a tool action, confirm its result and report the actual URL/state. If publication is blocked by permissions, authentication, network access, or a failed check, report the concrete blocker and preserve the prepared work.
