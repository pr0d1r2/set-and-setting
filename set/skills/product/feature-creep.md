# Feature creep

Feature creep is the unchecked expansion of scope beyond the original
requirements. Each addition seems small; together they delay delivery,
bloat complexity, and dilute the core value.

## Recognizing it

- "While we're at it" additions unrelated to the current task.
- Nice-to-have extras smuggled in alongside must-haves.
- Rounding out a feature with options, flags, or modes nobody asked for.
- Refactoring or generalizing code beyond what the task requires.
- Adding error handling, configuration, or fallbacks for scenarios that
  are not in scope.

## Preventing it

- Define done before starting. A task is finished when its stated
  requirements are met, not when it feels complete.
- Evaluate each addition against the original scope. If it was not
  requested and is not necessary for correctness, it is scope creep.
- Defer extras to a separate task. Capturing an idea as a future item
  costs nothing; embedding it in the current change costs review time,
  test surface, and delivery risk.
- Resist polish drift. Cosmetic improvements, naming cleanups, and
  structural refactors adjacent to a change are separate work.
- Ship the smallest correct change. Additional value belongs in the
  next iteration, not in a growing diff.
