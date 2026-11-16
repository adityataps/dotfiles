---
name: handoff-work
description: Use when transferring unfinished work to another agent or person, resuming in a new session, or preparing a compact continuation note.
---

# Handoff work

Produce a concise continuation note that lets the next worker act without reconstructing the conversation. Preserve the user's goal, accepted decisions, and current constraints.

## Handoff contents

- **Goal and status:** the intended result and what is complete, in progress, or blocked.
- **Location:** repository or artifact path, working branch, relevant commit/head, PR URL/state, and any uncommitted changes. Include only facts actually known.
- **Implemented work:** important files or artifacts and their purpose; separate implemented behavior from proposed work.
- **Verification:** commands/checks actually run, their results, and the revision they cover. Say explicitly when later changes remain untested. An old green run is not evidence for the current head.
- **Decisions and constraints:** agreed scope, important trade-offs, user preferences relevant to this task, and authorization limits that affect the next action.
- **Open issues:** reproducible failures, unresolved questions, external blockers, and failed attempts that would otherwise be repeated.
- **Next action:** the first concrete step, followed by the remaining sequence where useful. Include an exact command only when its path, inputs, and safety are understood.

Scale the note to the task; these fields can be short bullets rather than seven long sections. Link to authoritative files instead of pasting large code blocks or repeating the entire conversation. Mark unknown facts as unknown. Never include tokens, credentials, private URLs with embedded secrets, or unrelated personal context.

Example verification note: “Tests passed on `abc`; the editor reload change made afterward is untested. First rerun the shell regression tests on current HEAD, then check repeated sourcing before marking PR #7 ready.”

Return the handoff itself. Do not claim the next agent has read it or that a transfer, commit, or publication happened unless that action was actually performed.
