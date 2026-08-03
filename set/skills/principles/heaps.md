# Heaps's Law

Distinct information grows sublinearly as context grows. When shrinking
context, remove repetition before rare, decision-relevant details, then verify
that the smaller context can still support the next decision.

## Applying Heaps's Law

- Treat token count and information coverage as different measures. Use the
  empirical relation `V(n) = K n^beta` as a warning that a shorter text can
  retain a larger share of its distinct vocabulary than its token ratio alone
  suggests; estimate `K` and `beta` from the actual corpus when precision
  matters.
- Inventory distinct context before shrinking it. Record goals, constraints,
  decisions, unresolved questions, failures, identifiers, and source links so
  low-frequency facts do not disappear with repeated prose.
- Remove redundancy first. Collapse repeated explanations, routine logs, and
  interchangeable examples while retaining one clear statement and the
  evidence needed to trust it.
- Protect rare, consequential details explicitly. Frequency is not importance:
  a unique error, exception, negative result, or user constraint may govern the
  next action even though it occurs once.
- Preserve retrieval handles. Keep exact names, paths, commands, versions, and
  references that let a later agent recover omitted detail instead of replacing
  them with vague summaries.
- Shrink in layers. Keep a compact working set, a structured summary of prior
  state, and pointers to the full record; reload detail when the task crosses a
  decision boundary.
- Test the shrunken context. Ask whether it can reproduce the current goal,
  explain settled decisions, identify open risks, and choose the next action.
  Restore missing information before continuing.
- Measure repeated shrinkification as a lossy pipeline. Compare distinct facts
  and retrieval handles across generations, not only the final token count.

## Signals of violation

- A context is considered safe because it met a token target, without checking
  which distinct facts survived.
- A summary keeps common background but drops a one-off constraint, failure, or
  exact identifier.
- Every source token is treated as equally valuable, so useful repetition and
  irreplaceable evidence are compressed at the same rate.
- A formula derived from ordinary text is treated as a guaranteed retention
  ratio for a structured prompt, codebase, or deliberately written summary.
- Successive summaries are generated from the previous summary alone until
  claims, provenance, and unresolved questions drift away.
- The compact context has no pointers by which omitted evidence can be
  recovered.

## When vocabulary coverage conflicts with brevity

Heaps's Law describes an empirical type-token relationship, not semantic
importance and not a compression algorithm. Do not preserve every unique word
or use vocabulary count as a substitute for understanding. Keep the smallest
context that preserves the distinct facts and retrieval paths required by the
next decisions; reload the rest on demand. Use [[consequences]] to prioritize
rare details, [[truth]] to preserve provenance, and [[reality]] to test the
shrunken context against the source record.

Based on [Heaps's law](https://en.wikipedia.org/wiki/Heaps%27s_law), the
empirical observation that the number of distinct types in a text grows as a
sublinear power of its length, with diminishing returns as more text is added.
