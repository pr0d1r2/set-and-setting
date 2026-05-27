# Context: definitions

Enhance model understanding by loading precise word and concept
definitions into context. A local definitions directory acts as a
controlled vocabulary — reducing ambiguity without relying on model
training data.

## Rules

- Definitions live in `definitions/<domain>/<term>.md`.
- Each definition is one paragraph: the term, its meaning in this
  project, and how it differs from common usage if applicable.
- Load definitions on demand — only when the agent encounters an
  ambiguous term, not all at once.
- Definitions are authoritative within the project. If a definition
  conflicts with general knowledge, the definition wins.
- Keep definitions minimal. A definition that needs sub-definitions
  signals the concept should be split.
