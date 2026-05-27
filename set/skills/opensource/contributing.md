# Open-source: contributing

`CONTRIBUTING.md` at the repo root is the contributor-facing guide.
It covers setup, testing, code style, and commit conventions.

## Relationship to project conventions

CONTRIBUTING.md is a public summary. The full rules live in skills.

## When to update CONTRIBUTING.md

Update when:
- A new prerequisite is added to the dev environment
- Testing commands change
- A new file type gets a linter
- The commit convention changes

Keep it concise -- contributors should be productive after reading it
once. Detailed rules belong in skills, not in CONTRIBUTING.md.

## What CONTRIBUTING.md must not contain

- Internal infrastructure details (builder hostname, CI credentials)
- Security-sensitive procedures (credential injection, tunnel setup)
- Operator-specific workflows
