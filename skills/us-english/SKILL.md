---
name: us-english
description: Use when drafting or editing user-facing prose, documentation, comments, release notes, commit messages, or pull request text.
---

# US English

Use clear, natural US English in agent-authored prose. Preserve the meaning, technical accuracy, and audience's level of knowledge.

- Prefer US spellings such as color, organize, optimize, center, behavior, and license.
- Use active voice, concrete verbs, familiar words, and consistent terminology. Use the serial comma when it improves clarity.
- Preserve exact quotations, identifiers, flags, paths, commands, product names, and API names. A flag named `--colour` and a function named `normalise_colour()` stay unchanged. Do not rename program interfaces to enforce prose spelling.
- Honor an explicit target language, locale, or existing quoted source requested by the user. US English is the default, not a reason to mistranslate localized material.
- Do not infer US currency, jurisdiction, measurement units, addresses, or date interpretation from the writing preference. Use unambiguous dates and the user's actual context.

Example: “We optimised the colour picker. Run `app --colour blue`.” becomes “We optimized the color picker. Run `app --colour blue`.”

When editing, return the requested revised text. Explain a substantive ambiguity only if it affects meaning; do not append a spelling-change inventory to a simple edit.
