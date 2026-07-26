# Product: spec

`SPEC.md` is the project specification. It uses a compact notation
with six sections.

## Sections

| Section | Purpose | Format |
| ------- | ------- | ------ |
| G GOAL | One-paragraph project summary | Prose |
| C CONSTRAINTS | Design rules and boundaries | Numbered list |
| I INTERFACES | External touchpoints and commands | Named list |
| V INVARIANTS | Properties that must always hold | Numbered list |
| T TASKS | Implementation checklist | Table: id, status, task, cites |
| B BUGS | Known bugs with dates and fixes | Table: id, date, cause, fix |

## Verifying constraints

Each constraint and invariant should be verifiable against actual
code. When distilling SPEC.md:

1. Read the constraint
2. Find the implementing code
3. Check if the constraint accurately describes what the code does
4. Fix mismatches -- update SPEC to match code, not the other way
5. One commit per fix for clean review

## When to update

- **New constraint:** when a design decision affects multiple files
- **New invariant:** when a property must be preserved across future
  changes
- **New interface:** when a new command or external touchpoint is added
- **Task status:** mark done when implementation is complete
- **Bug entry:** when a bug is found and fixed, add with date and cause

## Backprop targets

A fixed bug has two possible durable homes, and they catch different
things. Ask about both, and record the answer in the bug entry so a
later reader can tell the question was asked.

| target | catches | misses |
| ------ | ------- | ------ |
| Invariant plus check | the failing **state**, mechanically, once it exists | a decision not yet made |
| Skill | the failing **choice**, before it is made | anything not expressible as guidance |

Choose by asking what would have prevented this:

- **Invariant** when the failure is a state a check can assert -- a
  file over a limit, a dangling reference, a missing required context.
- **Skill** when the failure is a choice the agent makes -- adopting a
  design, editing a generated file, preferring a tool. No check can
  assert that a choice was not made; by the time one can see it, the
  result already exists.
- **Both** when the choice is available and its result is also
  assertable. These are not alternatives.

A bug whose lesson lives only in the bug table will be relearned. The
skill set is a backprop target alongside invariants, not a separate
concern.
