# POLA / POLS as a design paradigm

The Principle of Least Astonishment (POLA), also called the Principle of
Least Surprise (POLS), is the design paradigm that optimizes for user
prediction accuracy: every interface should behave the way its user
would reasonably expect given its name, context, and surrounding
conventions.

## Design lens

Use POLA/POLS during interface design, API surface review, and module
decomposition as a tie-breaker: when multiple correct designs exist,
choose the one that surprises fewer consumers. The paradigm biases
toward:

- Naming by behavior, not mechanism.
- Safe, unsurprising defaults (dangerous operations require opt-in).
- Symmetric contracts (open/close, add/remove mirror each other).
- Localized side effects (a function does what its name promises,
  nothing more).

See `principles/pola.md` for the full application checklist, violation
signals, and guidance on justified surprises.
