---
name: inspect-repo
description: Use when starting work in an unfamiliar repository, onboarding an agent to a codebase, or locating architecture, entry points, conventions, and validation commands.
---

# Inspect a repository

Build a compact, evidence-based map before proposing changes. Read the codebase's instructions and existing workflows instead of inferring commands from a framework name.

1. Establish the repository root, branch, working-tree status, and applicable `AGENTS.md`, `CLAUDE.md`, or other project instructions. Preserve unrelated local work.
2. Read the README, manifests, task/build scripts, and CI definitions. Identify the stack and commands the project actually exposes.
3. Follow the main executable/library entry points into the parts relevant to the user's task. Find configuration, external dependencies, data boundaries, and representative tests.
4. Identify code style, directory boundaries, platform/version constraints, and deployment assumptions that matter to this change.
5. Run lightweight, safe checks when appropriate. Do not install dependencies, run bootstrap scripts, alter real configuration, or contact production systems merely to inspect the repository.

## Report

Provide the purpose and stack, a short path-to-responsibility map, relevant entry points, exact validation commands with their working directory, and material constraints or unknowns. Distinguish commands found in project files from commands actually run. Include one concrete next step tied to the user's goal.

Cite repository files for conclusions. Use fast file inventories and targeted searches, such as `rg --files` and `rg`, instead of dumping the entire repo or reading credentials. If tools or files are unavailable, state what cannot be established and identify the first files to inspect. Do not fabricate scripts, commands, architecture, or successful checks.

Example: if `package.json` defines `check` and `test:unit`, report those exact scripts; do not claim an unlisted `npm test` command exists or succeeds.
