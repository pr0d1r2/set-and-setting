# Finagle's Law

Anything that can go wrong will do so at the worst possible moment. Design for
failures to coincide with peak consequence: remove avoidable timing hazards,
reserve recovery capacity, and rehearse degraded operation before pressure
makes an ordinary fault critical.

## Applying Finagle's Law

- Identify critical moments as well as failure modes. Mark launches,
  migrations, deadlines, traffic peaks, dependency cutovers, staffing gaps,
  and irreversible steps where the same fault would be harder to detect,
  contain, or recover from.
- Remove single deadlines and narrow windows where practical. Stage changes,
  overlap old and new paths, keep rollback available, and finish risky work
  early enough to absorb a failed attempt.
- Preserve headroom for coincidence. Size time, capacity, staffing, and retry
  budgets so a routine fault during peak demand does not exhaust every means
  of recovery.
- Test at the worst credible boundary. Combine the failure with maximum load,
  partial dependency loss, an interrupted operator, stale state, or the last
  safe rollback point instead of testing each stressor only in isolation.
- Make recovery work under pressure. Keep procedures short, observable, and
  reversible; ensure the required people, credentials, tools, and backups are
  available when the primary path is not.
- Treat near misses caused by timing as design evidence. If a fault was
  harmless only because it happened during a quiet period, address the
  coupling before it recurs during a critical one.

## Signals of violation

- A risky deployment is scheduled immediately before a deadline, peak period,
  holiday, or loss of support coverage without a compelling constraint.
- Capacity, retry, or recovery plans assume failures arrive one at a time and
  under normal load.
- A rollback path exists but becomes unavailable after the most consequential
  migration step.
- Failure tests pass in isolation, but no test combines faults with the moment
  their impact would be greatest.
- A plan consumes all schedule or operational slack, leaving no room for
  diagnosis, retry, or safe retreat.

## When Finagle's Law conflicts with efficiency

Finagle's Law is a prompt to reduce time-dependent consequence, not a reason to
delay indefinitely or provision for every imaginable coincidence. Rank
critical moments by likelihood and impact, then buy margin where a modest
change materially improves detection, containment, or recovery. Use
[[consequences]] to set the reserve, [[murphy]] to cover the underlying failure
modes, and [[parkinson]] to keep contingency from becoming unbounded work.

Based on [Finagle's
Law](https://en.wikipedia.org/wiki/Finagle%27s_law), commonly rendered as the
observation that anything able to go wrong will do so at the worst possible
moment.
