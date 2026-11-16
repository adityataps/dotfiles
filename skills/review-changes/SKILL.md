---
name: review-changes
description: Use when reviewing a diff, commit, branch, or pull request, or when a user asks whether a change is ready to merge.
---

# Review changes

Review the actual change and its surrounding behavior. Lead with actionable findings supported by evidence, not a summary of how the code looks.

## Review process

1. Establish the exact base and head, task requirements, repository instructions, and changed files. Read complete affected paths and callers where needed; a diff alone may omit the relevant invariant.
2. Trace concrete inputs through validation, state changes, side effects, error handling, cleanup, and recovery. Check compatibility, authorization boundaries, data preservation, and regressions relevant to this change.
3. Reproduce suspected defects safely with focused checks or a minimal fixture. Separate confirmed behavior from inference. Run existing relevant checks rather than inventing a test result or assuming a green old commit covers a new head.
4. Classify findings by impact. Report correctness, security, or data-loss issues before optional maintainability concerns. Do not inflate preferences into blockers or request unrelated redesigns.
5. If the task authorizes fixes, make scoped corrections, verify them, and distinguish resolved findings from remaining issues. A review-only request produces findings without modifying the code or PR state.

## Output contract

For each unresolved finding, provide severity, a file/line or precise code location, the triggering condition, observable impact, and a concrete repair direction. Use P1 for a serious likely failure or data-loss/security issue, P2 for an ordinary correctness/regression issue, and P3 for a minor actionable issue. Reserve P0 for a release-blocking emergency with supporting evidence.

If there are no actionable findings, say so directly. Follow with the checks actually run, their results, and material coverage limitations. Explain any merge recommendation using the current head and checks. A self-review is not independent approval, and passing tests do not establish that every path is correct.

Example finding: “P2 — validate before persisting (`save_config`, validation branch). Invalid requests are written before the error response because `save()` now runs before `valid` is checked. Move the write after successful validation and cover invalid input with a regression test.”
