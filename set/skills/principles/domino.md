# Domino effect

Treat a change as the start of a possible chain, not as an isolated event.
Trace what it can enable or disrupt, validate every causal link, and add a
breakpoint before a local event can become an uncontrolled cascade.

## Applying the domino effect

- Name the initiating event and the affected system boundary. Distinguish what
  changed from conditions that merely make propagation possible.
- Draw the causal chain one link at a time: event, dependency, next event. Do
  not jump from the first event to the feared outcome without explaining the
  intermediate mechanism.
- Test the weakest link first. A cascade is only as credible as its least
  supported dependency; use a probe, canary, fault injection, or historical
  evidence to learn whether that link transmits the effect.
- Estimate reach and timing. Identify fan-out, shared dependencies, thresholds,
  and delays that can amplify a small trigger or hide propagation until later.
- Place circuit breakers at high-leverage links. Isolation, rate limits,
  staged rollout, validation gates, and rollback boundaries should stop or
  contain the chain before the next costly event.
- Observe links, not only endpoints. Instrument handoffs so the first failed or
  amplified transition is visible before the final outcome appears.
- Prefer reversible initiation. When the chain is uncertain, start with the
  smallest trigger whose effects can be halted and recovered independently.
- Re-evaluate after each observed transition. Evidence that one domino fell
  does not prove that every remaining domino must fall.

## Signals of violation

- A change is called local even though it modifies a shared dependency or
  condition used by many consumers.
- A catastrophic endpoint is asserted from a small trigger without evidence
  for the intermediate causal links.
- Controls exist only at the end of the chain, after most damage has already
  propagated.
- Monitoring reports the final failure but cannot identify which handoff first
  transmitted or amplified it.
- A rollout continues after an early transition behaves differently from the
  model because the remaining sequence is assumed to be inevitable.
- Recovery requires reversing the whole cascade instead of isolating the
  affected stage.

## When cascade reasoning conflicts with simplicity

Do not invent a long chain for every change. A short, isolated, observable, and
easily reversible action may need only a direct check. Spend more effort when
dependencies are shared, propagation is fast, fan-out is large, or recovery is
expensive. Keep possibility separate from probability: treating every imagined
sequence as inevitable is the domino fallacy. Use [[consequences]] to compare
downstream costs, [[assumptions]] to expose unsupported links, and [[surgical]]
to limit the initiating change and its blast radius.

Based on the [domino effect](https://en.wikipedia.org/wiki/Domino_effect): one
event can set off a linked sequence of related events, while an unsupported
claim that the sequence must continue is a domino fallacy.
