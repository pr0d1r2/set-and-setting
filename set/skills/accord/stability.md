# Stability

Try to make the change fail in operation. Trace changed paths through normal,
boundary, repeated, concurrent, and failure execution. Seek evidence of a
regression rather than inferring safety from a green happy path.

Check that:

- Existing observable behavior remains stable unless the change explicitly
  and safely revises it.
- State transitions are deterministic. Shared or concurrent state has clear
  ownership and ordering; no race, flaky timing assumption, unbounded retry,
  or sleep-based correctness hides in the change.
- Operations that may be repeated, retried, resumed, or reconciled are
  idempotent where their contract requires it.
- Inputs, missing state, partial progress, dependency failures, cancellation,
  and cleanup have deliberate outcomes. Errors retain enough context to be
  diagnosed and do not leave corrupt or ambiguous state.
- Resource lifetimes, defaults, and boundary values do not introduce a
  behavioral or runtime regression outside the primary path.

Discord includes any reproducible regression, timing-dependent correctness,
unsafe partial failure, or claimed stability without evidence for an affected
path. Accord only when the relevant failure modes have been exercised or are
otherwise convincingly ruled out.
