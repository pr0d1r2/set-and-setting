# TDD

We work in Test Driven Development scheme.
Ensure every implementation is covered with 1-to-1 unit test.

## The commit is the gate

Write the test first and run it. Confirm it fails, and confirm it
fails for the right reason -- the assertion you meant, not a syntax
error or a missing import. A failure that carries no information
about the fix is not a useful RED.

Keep that failing state in the working tree. Do not commit it. The
pre-commit suite runs the full guardrail set, so a commit only comes
into being once the test passes. The gate passing is the proof that
the RED-GREEN cycle completed; no separate step is needed to show
the test came first.

Drive the implementation to green, then commit the test and the
implementation together. One commit per RED-GREEN cycle.

## Refactor after the cycle

Refactor once the cycle is committed and green. Tests do not change
during a refactor. If they must change, that is a new cycle, not a
refactor.

Commit each refactor on its own, so it can be reverted on its own.

Make separate commit if spec has to be adjusted.

## Why no red state in history

Every commit is independently checkable. Bisect stays useful, and
every commit builds.

A failure seen on another machine is then always real -- an
environment gap, a platform difference, or a true defect. It can
never be a broken state inherited from history.
