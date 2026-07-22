# Test accord

Try to prove that the tests would stay green after the implementation breaks.
Map every changed invariant and observable behavior to an assertion that would
fail under a plausible regression.

Check that:

- Every new or changed behavior has a focused test, with one clear test case
  per invariant or behavior when practical.
- Relevant boundaries and failure modes are covered, not only the successful
  path. Regression fixes reproduce the defect before demonstrating the fix.
- Assertions observe real outcomes at the appropriate boundary. They do not
  merely assert a stub call, restate fixture data, duplicate the implementation,
  or pass tautologically.
- Test doubles isolate irrelevant dependencies without replacing the behavior
  under review. Fixtures and setup can actually reach the claimed branch.
- Tests are deterministic and independent of ordering, ambient machine state,
  wall-clock luck, network availability, or leakage from another test.

Mentally or experimentally introduce a representative regression. If no test
fails, the coverage is theater and the verdict is discord. New behavior without
a new test is discord unless existing tests demonstrably exercise that exact
behavior and would fail on regression.
