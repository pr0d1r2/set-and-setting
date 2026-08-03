# Infinite Monkey

Use the infinite monkey theorem as a stress test for search strategies. A
generator that gives every symbol a nonzero chance will, over unbounded
independent trials, almost surely produce any finite target. Real work has
finite time, compute, attention, and validation capacity, so possibility alone
does not make a search strategy useful.

Almost sure is not the same as certain, and an infinite-horizon result is not a
finite-time guarantee. Do not use the theorem to justify blind random search.
Use it to expose whether a plan relies on enough unstructured attempts somehow
producing a correct result.

## Applying the thought experiment

- Define a recognizable target. If success cannot be tested, generating more
  candidates cannot establish that one is correct.
- Estimate the search space before sampling it. Treat exponential growth as a
  warning that unguided enumeration will exhaust any practical budget.
- Give viable regions nonzero probability. Avoid generators, assumptions, and
  filters that make a valid solution unreachable.
- Prefer diverse, independent attempts when the solution is uncertain. Change
  approaches, starting points, or models instead of repeating the same likely
  failure with cosmetic variation.
- Validate every candidate with a deterministic oracle where possible. Random
  generation may propose an answer; tests, constraints, or observation decide
  whether it works.
- Feed evidence back into the generator. Preserve useful partial structure,
  discard disproved branches, and bias later attempts toward what was learned.
- Stop when the budget expires or expected information gain becomes too low.
  Report the explored space and remaining uncertainty rather than claiming
  that more attempts must eventually succeed.

## Experiment

For a problem whose solution is not yet known, write five lines:

1. **Target** -- What exact, finite outcome would count as success?
2. **Generator** -- Which candidates can the search produce, and which can it
    never produce?
3. **Oracle** -- What repeatable check distinguishes success from plausible
    noise?
4. **Budget** -- How many attempts, how much time, and how much review can the
    search spend?
5. **Learning** -- How will each result change the distribution of later
    attempts?

Run a small batch. Compare blind sampling with feedback-guided sampling using
the same oracle and budget. Keep the less complex strategy when both perform
similarly; otherwise use the evidence to narrow the generator. Stop when the
budget expires, even if the theorem promises success only in the limit.

## Signals of failure

- A large number of attempts substitutes for defining success.
- Candidates are varied in appearance but share the same hidden assumptions.
- A correct candidate is possible in theory but effectively unreachable under
  the generator and budget.
- An evaluator rewards plausible output without checking the target property.
- Failed trials are discarded without updating later trials.
- Parallel generation creates more review work than the oracle can absorb.
- Continued sampling is defended with "eventually" after the stopping rule has
  been reached.

## Limits

The theorem assumes unbounded trials and a process capable of producing the
target. It says nothing about whether a target is well specified, whether an
oracle is sound, or whether success arrives within a useful time. Randomness is
valuable for diversity and escaping local assumptions, not as a replacement
for decomposition, domain knowledge, or verification.

Based on the [Infinite monkey
theorem](https://en.wikipedia.org/wiki/Infinite_monkey_theorem), especially the
distinction between almost-sure occurrence in an infinite sequence and the
extreme improbability of useful finite results.
