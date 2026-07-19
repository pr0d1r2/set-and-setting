# Ops: HITL

Human in the Loop (HITL) — define gates where autonomous agent
execution must pause and yield to a human for review, approval, or
decision before proceeding.

## When to gate

- Irreversible actions: data deletion, production deploys, access
  revocation, secret rotation.
- Ambiguous intent: the spec or task is underspecified, multiple valid
  interpretations exist, or the confidence threshold is not met.
- Boundary crossings: actions that leave the local sandbox (push, post,
  message, publish, API call to external service).
- Policy-sensitive changes: license modifications, security
  configuration, user-facing behavioral changes.
- Escalation: the agent exhausted its retry budget or hit an
  unrecoverable error that requires human judgment.

## How to gate

- Mark the gate in SPEC.md: `HUMAN-GATED` prefix on the task row
  (column `s` stays ` ` until the human acts, then `x`).
- The agent stops, emits a structured summary (what, why, options,
  recommendation), and waits.
- No partial execution past the gate — the action is atomic from the
  gate forward.
- The human response is: approve, reject, or redirect (new
  instructions).
- On approve: agent proceeds with the gated action.
- On reject: agent records the rejection reason and moves to the next
  task.
- On redirect: agent replans from the new instructions.

## SPEC.md anchors

Projects supporting HITL mark gated tasks in their `§T Tasks` table:

```markdown
| T99 |   | HUMAN-GATED — description of the gated action | cites |
```

The `HUMAN-GATED` prefix is the anchor. It signals:

1. The task requires human approval before execution.
2. Autonomous loops must not auto-complete it.
3. The agent must surface it with enough context for the human to
    decide.

## Autonomous loop integration

When an agent operates in a loop (scheduled, cron, or continuous):

- Scan `§T Tasks` for `HUMAN-GATED` entries before planning.
- Skip gated tasks unless the human has explicitly approved them in
  the current session.
- Accumulate gated items into a review queue surfaced at loop
  boundaries.
- Never decompose a gated task into ungated subtasks to bypass the
  gate.
