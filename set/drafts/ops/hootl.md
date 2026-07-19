# Ops: HOOTL

Human out of the Loop (HOOTL) — let an autonomous agent act without
per-action approval inside an explicit, observable, reversible envelope.

## Define the envelope

- State the objective, allowed resources, decision rights, and actions
  that remain forbidden.
- Set budgets for time, cost, retries, concurrency, and change size.
- Require deterministic checks and a recoverable checkpoint before each
  independently risky change.
- Define success, stop, rollback, and escalation conditions before the
  loop starts.
- Keep credentials and permissions at the least privilege needed for the
  declared envelope.

## Operate the loop

- Select only work marked `HOOTL-ELIGIBLE` in `SPEC.md`.
- Observe progress through durable logs, task state, check results, and
  produced artifacts.
- Commit small green changes so a failed iteration can be reverted or
  resumed without repeating completed work.
- Stop on a budget limit, repeated failure, lost observability, an
  ambiguous objective, or a boundary outside the declared envelope.
- Escalate stopped work through the HITL gate; never expand authority to
  keep the loop moving.

## SPEC.md anchors

Projects tended by an autonomous loop define the operating envelope in
`§C Constraints` and its observable control surface in `§I Interfaces`.
They mark autonomous tasks in `§T Tasks`:

```markdown
| T98 |   | HOOTL-ELIGIBLE — bounded autonomous task | cites |
| T99 |   | HUMAN-GATED — action outside the envelope | cites |
```

The paired anchors are mandatory. `HOOTL-ELIGIBLE` grants authority only
within the documented envelope. `HUMAN-GATED` reserves exceptions for
HITL review. An unmarked task receives no HOOTL authority.

## Review the loop

- Surface completed work, skipped gates, exhausted budgets, and rollback
  events at every loop boundary.
- Revoke HOOTL eligibility when checks become unreliable or the envelope
  no longer matches the project.
- Require a human to approve changes to the envelope, budgets, or gate
  classification.
