# Transparency

Radical transparency. Make reasoning and decisions visible and auditable
to others (and future-you). Truth kept private cannot be checked;
transparency lets the machine be inspected.

## Applying transparency

- Cite the invariants, constraints, or prior decisions a change respects.
  A commit that silently relies on V12 or C2 is harder to review than one
  that names them.
- Stamp trips with a PROFILE -- record the agent, model, parameters, and
  session context so any output can be traced to its origin.
- Emit heartbeats and progress signals. A long-running task that produces
  no intermediate output is indistinguishable from a hung one.
- Keep an audit-trail commit history. Each commit captures one logical
  change with a message explaining why, not just what. Squashing away the
  reasoning defeats the trail.
- Leave breadcrumbs for the next reader. When a non-obvious choice is
  made (a workaround, a deliberate omission, a performance trade-off),
  note the reason at the decision site so it survives beyond the current
  conversation.

## Signals of violation

- A change is made with no commit message explaining the motivation, only
  a description of the diff.
- Reasoning lives only in a chat transcript that will expire -- not in
  the code, commit, or spec where a future reader would look.
- A task runs for minutes with no status output; the operator cannot tell
  whether it is working or stuck.
- A decision references "we discussed this" without citing what was
  decided or why.
- An automated process produces results with no record of the inputs,
  parameters, or version that generated them.

## When transparency conflicts with brevity

Not every micro-decision needs a paper trail. Transparency targets the
decisions that someone will later need to understand, verify, or reverse.
A one-line typo fix does not need a paragraph of justification; a
guardrail bypass or an architectural trade-off does. Calibrate the depth
of the trail to the stakes of the decision.
