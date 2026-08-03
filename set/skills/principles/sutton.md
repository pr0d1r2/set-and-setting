# Sutton's law

When diagnosing a problem, first test the most likely explanation. Start where
the evidence is concentrated, using the cheapest reliable check that can
confirm or rule out the obvious cause before pursuing remote possibilities.

## Applying Sutton's law

- State the observed failure before naming a cause. Separate direct evidence
  from assumptions so a familiar symptom does not become an untested diagnosis.
- Rank plausible causes using the current evidence, base rates, and the system's
  actual failure history. Begin with the leading explanation, not the most novel
  one.
- Choose the next check for information gained relative to its cost, delay,
  risk, and reversibility. Prefer a fast, safe test that distinguishes likely
  causes over broad collection or invasive experimentation.
- Define in advance what result would confirm or rule out the leading cause.
  If the result contradicts it, update the ranking instead of repeating the
  check or bending the explanation around the evidence.
- Inspect the direct path to the suspected source. Reproduce the failing input,
  read the reported error, check the relevant state, and trace the nearest
  dependency before searching unrelated layers.
- Escalate deliberately. Move to rarer causes or more expensive tests when
  likely causes have been tested, evidence points elsewhere, or delay costs
  more than the investigation.
- Preserve high-consequence alternatives. Check a less likely cause early when
  missing it could cause irreversible harm, security exposure, data loss, or
  the loss of a narrow recovery window.
- Record the hypothesis, test, result, and updated ranking so another person or
  agent can continue the diagnosis without restarting it.

## Signals of violation

- Diagnosis starts with an exotic edge case while a common, directly testable
  cause remains unchecked.
- Logs, errors, failing inputs, or nearby state are ignored in favor of broad
  searches and speculative changes.
- Tests are ordered by habit or sophistication rather than likelihood,
  discriminating power, cost, and consequence.
- A plausible first guess is treated as established fact, and conflicting
  evidence is dismissed or the same check is repeated without updating it.
- A rare but catastrophic cause is excluded solely because it is rare.
- Several variables are changed at once, so a passing result cannot identify
  which hypothesis was correct.

## Limits

Sutton's law is a prioritization heuristic, not proof that the obvious answer is
correct. Base rates can mislead when the sample is biased, the system has just
changed, failures are correlated, or an adversary is involved. Account for
false positives, test reliability, and asymmetric consequences; a cheap test
that produces ambiguous evidence may be worse than a focused expensive one.
After identifying the likely cause, apply [[rootcause]] so the repair prevents
the failure class rather than masking its symptom, and apply [[consequences]]
when choosing how aggressively to test or intervene.

Based on [Sutton's law](https://en.wikipedia.org/wiki/Sutton%27s_law), the
diagnostic principle of first considering the obvious and ordering tests to
reach a likely diagnosis quickly while avoiding unnecessary cost.
