# Skill: format

Every skill file follows a fixed structure so tooling can lint,
compose, and budget them mechanically.

## Structure

- Filename: `<topic>.md` or `<topic>/<aspect>.md`.
- First line: `# <Title>` — one heading, the skill name.
- Body: rules, not explanations. Imperative sentences.
- No front-matter, no YAML, no metadata blocks.
- Maximum one level-2 heading per distinct concern.
- Cross-references use `@` relative paths to other skills.

## Constraints

- One concept per file. If a file covers two independent concerns,
  split it.
- Skill files contain only markdown. No executable code, no
  configuration fragments, no embedded scripts.
- File must be parseable by any CommonMark renderer.
