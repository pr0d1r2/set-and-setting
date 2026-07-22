# Accord review

The accord is an adversarial merge gate, not a rubber stamp. Actively try to
find concrete discord between the proposed change and each lens before giving
it an accord verdict. Green automation is necessary evidence, but it does not
replace this review.

Review the change with every sibling lens. For each lens, report exactly one
verdict:

- `accord` -- give a concrete reason, grounded in the diff and its evidence,
  that the change satisfies the lens.
- `discord` -- identify the concrete defect, risk, or missing evidence and the
  part of the change it affects.

Report an overall `PASS` only when all five lenses accord. Any concrete discord
means the change does not merge. Send it through a fix trip, or escalate to a
human when resolving it requires human judgment or authority. Never average
away, outvote, or silently waive a discord.

Judge the behavior and evidence rather than the language, framework, or stack.
Review only what the change can affect, but follow relevant consequences across
component and consumer boundaries.
