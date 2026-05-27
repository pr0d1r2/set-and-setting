# Skill: size budget

Every skill file has a token budget. Loading skills into an agent
context window is a zero-sum game — each skill competes with code,
conversation, and other skills for space.

## Rules

- Individual skill file: 500 tokens max.
- Bundle file (composing atomics via `@`): 100 tokens own content max,
  rest is `@` references.
- Measure with `wc -w` as rough proxy (1 word ~ 1.3 tokens).
- If a skill exceeds budget, split into atomic sub-skills and compose
  via bundle.
- Prefer terse imperative rules over explanatory prose.
