# Test: not believing

Never trust a spec (test) you never saw failing.

## Establish trust

1. Write the test before the implementation or behavior change.
2. Run the narrowest relevant test before implementation.
3. Confirm that it fails for the intended reason: the assertion must expose the
    missing or incorrect behavior, not a syntax, setup, import, or environment
    error.
4. Make the smallest change that should satisfy the test.
5. Run the narrow test again, then the broader relevant suite.

A test that passes before the change proves nothing about the change. It may
exercise the wrong path, assert the existing behavior, or contain an assertion
that cannot fail.

## Existing implementations and regressions

When adding a test around code that already passes, first reproduce the old
behavior: restore the defect or temporarily reverse the condition that the test
is meant to protect. Run the test and observe the expected failure, then undo
the temporary change and confirm green. Do not commit the deliberately broken
state.

If reproducing the failure would be destructive, unsafe, or dependent on an
unavailable system, use the smallest safe substitute that exercises the same
boundary. State what was not observed directly and why; do not present an
unseen RED as evidence.

## Preserve the evidence

- Record the failing command and the reason it failed in the work log or pull
  request when the development trace matters.
- Keep every commit green. Commit the test with the implementation that makes
  it pass.
- Reject a test whose only observed failure is unrelated to its assertion.
- Re-run the relevant suite after refactoring; a previous RED does not excuse a
  new regression.
