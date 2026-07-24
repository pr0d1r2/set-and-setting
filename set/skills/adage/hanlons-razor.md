# Hanlon's razor

Never attribute to malice that which is adequately explained by
ignorance, miscommunication, or honest mistake.

## Applying Hanlon's razor

- When reviewing code that looks wrong, assume the author lacked context
  or misunderstood the requirement before assuming carelessness or
  indifference. Frame feedback around the gap, not the person.
- When a system fails unexpectedly, start with the simplest causal
  hypothesis -- a misconfiguration, a missed edge case, a stale
  dependency -- before suspecting intentional sabotage or negligence.
- When a teammate's change breaks something, default to "they didn't
  know" rather than "they didn't care." The fix is the same either way;
  the collaboration is not.
- When an upstream library behaves oddly, check for bugs, version
  mismatches, or documentation gaps before concluding the maintainers
  made a hostile design choice.
- When a CI pipeline fails after someone else's merge, investigate the
  interaction between changes before assuming the other contributor
  ignored the test suite.

## Signals of violation

- A code review comment implies the author was lazy or reckless without
  evidence of intent.
- A post-incident report assigns blame to a person rather than
  identifying the process or system gap that allowed the error.
- A discussion escalates because one side assumes the other is acting in
  bad faith when a simpler explanation -- different context, different
  priorities, or a plain mistake -- fits the facts.
- A design proposal is dismissed as "deliberately ignoring" constraints
  that the proposer may simply not have known about.

## Limits

Hanlon's razor is a starting assumption, not a permanent conclusion.
When evidence of genuine negligence or bad faith accumulates --
repeated identical mistakes after clear feedback, willful disregard of
documented policy, or pattern of harm -- update the explanation
accordingly. The razor says start with charity, not end there.
