# Confirmation bias

Actively seek evidence that could prove the current belief wrong.
Confirmation bias favors information that supports an existing belief
when searching for, interpreting, and recalling evidence. A plausible
first explanation is a hypothesis to test, not a conclusion to defend.

## Countering confirmation bias

- Write down what would disprove the working hypothesis before testing
  it. Prefer checks that distinguish it from credible alternatives over
  checks that can only confirm it.
- Search for disconfirming evidence. Inspect failing and passing cases,
  contrary logs, competing implementations, and history that predates
  the favored explanation.
- Generate at least one plausible alternative explanation. Design the
  next test around where its prediction differs from the current one.
- Apply the same evidence standard to favored and competing hypotheses.
  Do not dismiss contrary results for limitations you tolerate in
  supporting results.
- Separate observation from interpretation. Record the command, output,
  or source first; then state what it supports, contradicts, or leaves
  unresolved.
- Record evidence that changed the conclusion. When a test contradicts
  the working belief, update the diagnosis instead of repeating a more
  favorable version of the same test.
- Invite adversarial review for consequential decisions. Ask reviewers
  what evidence is missing and what result would reverse their judgment.

## Signals of violation

- Tests exercise only the expected happy path or reproduce only the case
  that supports the proposed fix.
- Investigation stops after finding one fact consistent with the first
  diagnosis.
- Contrary evidence is called flaky, irrelevant, or exceptional without
  applying equivalent scrutiny to supporting evidence.
- A search query, benchmark, or comparison is framed so that the favored
  answer is the only likely result.
- A conclusion remains unchanged after its stated falsification condition
  occurs.

## Limits

Do not manufacture false balance. Strong, replicated evidence should
outweigh a weak counterexample, and settled facts do not require endless
re-litigation. The aim is calibrated confidence: test meaningful
alternatives early, weigh all results consistently, and then act on the
best-supported explanation.
