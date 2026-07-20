# Progress

Pain + Reflection = Progress. Treat every failure and painful signal as
fuel: reflect on it, extract the lesson, and encode the improvement so
it compounds. Pain avoided is progress lost.

## Applying progress

- On a failure, backprop the cause into a durable rule so it cannot
  recur. A bug that was fixed but not encoded (guardrail, test,
  invariant) will resurface -- the fix is temporary, the rule is
  permanent.
- Mine logs in the introspect loop. CI output, tend logs, error traces,
  and review feedback are ore -- each contains a signal about what went
  wrong and why. Extract it, refine it, deposit it where it will fire
  next time.
- Each mistake makes the machine better. A failure that produces no
  encoded improvement is a wasted failure. The value of the pain is the
  lesson; the value of the lesson is the rule; the value of the rule is
  that the mistake never happens again.
- Seek discomfort, not comfort. Avoiding hard problems, difficult
  feedback, or uncomfortable truths feels safe but starves the
  improvement loop. Lean into the signal.
- Close the loop quickly. The shorter the gap between failure and
  encoded fix, the less context is lost and the faster the system
  improves. A lesson journaled next week is worth less than a rule
  committed today.

## Signals of violation

- A failure occurs and the only response is a fix -- no guardrail, test,
  or invariant is added to prevent recurrence.
- The same class of mistake appears more than once because the first
  instance was patched but never encoded.
- Painful feedback is dismissed or avoided instead of mined for
  improvement.
- Logs, error output, or review comments are skimmed or ignored rather
  than systematically processed for lessons.
- Comfort is chosen over growth -- easy tasks are picked, hard feedback
  is deferred, and the improvement rate flatlines.

## When progress conflicts with velocity

Not every failure justifies a new rule. Encoding a one-off edge case as
a permanent guardrail can add friction that slows future work without
preventing a realistic recurrence. Calibrate: if the failure class is
likely to recur or its cost is high, encode it immediately. If it was
truly singular, document the lesson in the commit message and move on.
The goal is compound improvement, not bureaucratic overhead.
