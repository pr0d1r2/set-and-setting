# Wiio's laws

Communication usually fails, except by accident. Design every consequential
message for the receiver to understand, verify, and act on; do not treat sending
as proof that meaning arrived.

## Applying Wiio's laws

- Start from the receiver's context. State the audience, shared facts, intended
  outcome, and required action instead of relying on knowledge that only the
  sender has.
- Put the decision or request first. Separate facts, assumptions, proposals,
  questions, and commitments so the receiver can tell what is known and what
  must happen next.
- Search for the most damaging plausible interpretation. Remove ambiguous
  pronouns, overloaded terms, hidden defaults, and unclear scope; add examples
  or boundaries where misreading would be costly.
- Close the loop on consequential messages. Ask the receiver to paraphrase the
  decision, action, owner, and deadline; resolve differences against the source
  rather than accepting an unexamined acknowledgment.
- Treat agent handoffs as communication across unequal contexts. Preserve the
  goal, constraints, decisions, evidence, exact identifiers, completed work,
  failures, and next action in a durable artifact another agent can inspect.
- Prefer one authoritative message over accumulating explanations. Update or
  link to the source of truth, mark superseded guidance, and summarize changes
  so misunderstandings do not propagate faster than corrections.
- Match the channel to the consequence. Use durable, reviewable communication
  for decisions and handoffs; use ephemeral conversation for exploration, then
  record the settled result.
- Before a high-stakes send or handoff, use a checklist for essentials that are
  easiest to omit under pressure: recipient, intent, evidence, action, owner,
  timing, constraints, and recovery path.
- In broad communication, inspect how the message will appear without its
  original context. Headlines, summaries, status labels, and ordering shape
  interpretation even when the detailed facts are accurate.

## Signals of violation

- Delivery, silence, an acknowledgment, or a successful tool call is treated as
  proof of shared understanding.
- A message is clear only to someone who already knows the sender's assumptions.
- Several interpretations are possible and nobody tests the one with the
  greatest potential harm.
- More messages, agents, or channels are added without an authoritative record,
  causing stale interpretations to multiply.
- A handoff reports activity but omits the goal, decisions, failures, evidence,
  or exact next action needed to continue safely.
- An urgent message relies on memory and omits an essential recipient,
  constraint, dependency, or recovery step.

## Limits

Wiio's laws are humorous, pessimistic observations, not proof that every
communication fails or that receivers act in bad faith. Do not respond with
paralyzing verbosity, demand confirmation for trivial reversible exchanges, or
shift all responsibility to the receiver. Match redundancy and verification to
the consequences, invite correction, and improve the shared record when a
misunderstanding reveals a missing assumption. Apply [[concise]] to control
volume, [[truth]] to distinguish claims from assumptions, and [[consequences]]
to choose the strength of the communication check.

Based on [Wiio's laws](https://en.wikipedia.org/wiki/Wiio%27s_laws), Osmo
Wiio's humorous observations that communication usually fails, ambiguous
messages tend toward damaging interpretations, more communication can spread
misunderstandings, appearances dominate mass communication, and essential
details are easiest to forget in important situations.
