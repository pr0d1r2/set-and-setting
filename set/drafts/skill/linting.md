# Skill: linting

Skill files are linted for quality before merge. Automated checks
enforce format consistency across the tree.

## Checks

- markdownlint: CommonMark compliance.
- First line must be `#` heading.
- No duplicate headings within a file.
- No empty sections (heading with no content before next heading).
- Token budget check: file word count within limit.
- No executable code blocks (``` with language tag) — skills are
  prose rules, not runnable code.
- `@` references resolve to existing files in the tree.
