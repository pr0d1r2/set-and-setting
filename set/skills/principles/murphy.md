# Murphy's Law

Anything that can go wrong eventually will. Treat every credible failure mode
as a design input: prevent it where practical, detect it quickly, and contain
its impact when prevention fails.

## Applying Murphy's Law

- Enumerate how the change can fail before shipping it. Include invalid input,
  partial execution, timeouts, unavailable dependencies, exhausted resources,
  concurrency, and interrupted recovery when they are relevant.
- Make the wrong action impossible or obvious. Remove ambiguous choices, use
  safe defaults, validate at boundaries, and encode invariants so correctness
  does not depend on perfect attention.
- Exercise failure paths deliberately. Test negative cases, inject faults at
  important boundaries, and verify that rollback and recovery work before an
  incident makes them necessary.
- Add defense in depth in proportion to the consequence. Use independent
  checks, redundancy, idempotency, bounded retries, and graceful degradation
  where one failure would otherwise cause unacceptable harm.
- Fail visibly and locally. Preserve diagnostic context, alert on actionable
  symptoms, and isolate faults so one bad component or input cannot silently
  corrupt the wider system.
- Learn from every near miss. A failure that was possible but happened not to
  occur is still evidence of a design gap; close it before repetition turns
  possibility into an incident.

## Signals of violation

- A happy-path test is treated as proof that production behavior is safe.
- A dangerous operation relies on a warning or operator memory when the unsafe
  choice could have been eliminated or guarded.
- Recovery exists only as an untested document, or depends on the same
  component whose failure requires recovery.
- A partial failure can leave corrupt state with no detection, rollback, or
  safe retry path.
- A known failure mode is dismissed because it is unlikely, despite having a
  consequence that warrants a cheap mitigation.

## When Murphy's Law conflicts with simplicity

Murphy's Law is a prompt for risk-based design, not a claim that every imagined
event deserves machinery. Rank failure modes by likelihood, impact,
detectability, and mitigation cost. Address credible risks where the safeguard
cost is justified; document and accept the rest. Preserve [[kiss]] and
[[yagni]] while using [[consequences]] to decide which defenses earn their
complexity.

Based on the engineering interpretation of
[Murphy's Law](https://en.wikipedia.org/wiki/Murphy%27s_law): consider what can
go wrong, then plan and add safeguards against it.
