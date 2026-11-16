---
name: technical-documentation
description: Use when writing or updating READMEs, setup guides, tutorials, API references, architecture explanations, or other developer documentation.
---

# Developer documentation

Write task-oriented documentation in clear US English, using the Google developer documentation style as the default. Match the reader's knowledge and the repository's established terminology. Preserve technical accuracy over stylistic polish.

## Structure

- Lead with what the reader can accomplish and when the instructions apply.
- For a how-to, include necessary prerequisites, ordered actions, and an observable success check. Add troubleshooting for likely failures that the available evidence supports. Omit empty or unnecessary sections.
- For a reference, explain the purpose, inputs, outputs, errors, and a small realistic example. For an explanation, connect the mechanism to its consequences before adding implementation detail.
- Use sentence-case headings, descriptive link text, parallel lists, and tables for exact comparisons. Prefer active voice, second person where helpful, and imperative steps.

## Markdown source formatting

Keep each prose paragraph on one physical line. Do not manually hard-wrap paragraphs at 80 or 100 columns and do not insert `<br>` or Markdown hard breaks to control prose layout. Blank lines still separate paragraphs, headings, lists, and code blocks. Give separate list items their own lines. Preserve meaningful newlines in code, commands, output, tables, and examples; this rule does not flatten structured content.

## Accuracy and examples

1. Read the affected code, configuration, and existing documentation. Verify version-sensitive behavior against current primary documentation when needed.
2. Write commands that match the actual interface, working directory, prerequisites, and platform. Use `.yaml` for new YAML filenames unless a tool requires another exact name.
3. Include the expected result and relevant failure behavior. Mark placeholders clearly. Do not invent command output, benchmarks, supported platforms, or successful test runs.
4. Check links and run safe examples when possible. Avoid using the reader's real home, production data, credentials, or destructive commands to validate documentation.
5. Return the edited artifact and a concise account of substantive changes and verification. State what could not be checked.

Use code formatting for identifiers and commands. Preserve exact API spelling, flags, filenames, output, and quoted material even when they differ from US English. Avoid marketing language, unexplained jargon, and procedural detail that the reader does not need.

Reference: [Google developer documentation style guide](https://developers.google.com/style/highlights). Apply its principles proportionally; do not copy an unrelated page's structure into every document.
