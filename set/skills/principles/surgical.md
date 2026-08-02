# Surgical

Change only what the task requires. Touch the lines that address the
stated problem, preserve the surrounding style and structure, and leave
unrelated code alone.

An improvement smuggled into an unrelated diff is not free -- it costs
review attention and hides the change that matters.

## Applying surgical

- Scope the diff to the reported problem before writing it. Name the
  files and the behavior the task changes; anything outside that set
  needs its own justification, not a ride along.
- Match the surrounding style even when you would write it differently.
  Quote style, naming, spacing, error idiom, and comment density belong
  to the file, not to the author of the current change. A consistent
  file is worth more than a locally optimal line.
- Keep refactors separate. A rename, an extraction, or a reformat is its
  own commit so it can be reviewed and reverted on its own. The same
  holds after a red-green cycle: refactor once the fix is committed and
  green, never inside it.
- Add nothing that was not asked for. Unrequested validation, error
  handling, configuration, type annotations, and docstrings expand the
  test surface and the review cost without expanding the delivered
  value.
- Watch the tools that edit for you. A formatter run on save, an
  auto-import, or an editor rewrite can widen a two-line fix into a
  whole-file diff. Inspect the staged hunks before committing, not the
  intent behind them.
- When the change genuinely cannot be made without touching surrounding
  code -- a symbol used elsewhere, a signature every caller passes --
  say so, and keep the mechanical part in a commit of its own.

## Signals of violation

- A bug-fix diff contains whitespace-only or reformatting hunks.
- A commit touches files that the reported problem never named.
- Quote style, imports, or annotations change in a function unrelated to
  the fix.
- A reviewer has to ask which hunk actually fixes the reported issue.
- A rename or an extraction rides along inside a behavior change, so
  reverting the behavior also reverts the cleanup.
- The diff is large and the description is one sentence, because most of
  the diff has no description to give.

## When surgical conflicts with improvement

Adjacent rot is real, and noticing it is useful. Surgical is not a rule
against fixing it -- it is a rule about where the fix lands. Capture the
cleanup as its own commit on the same branch, or as a follow-up task,
and state that you saw it. Deferring an improvement keeps it available;
burying it inside an unrelated diff spends review budget on it without
anyone choosing to. Weigh the downstream cost of a wide diff before
widening it. See also [[consequences]], [[kiss]], and [[transparency]].
