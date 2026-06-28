# Mechanism probes

Integration suite (V31, T50) that **empirically verifies** Claude Code's
loading semantics the multi-channel emit design (V17-V21, V29) depends
on -- instead of trusting docs. Each probe plants a unique marker token
in a `.claude/` fixture, runs headless `claude -p`, and checks whether
the token comes back, i.e. whether that fixture loaded.

## Run

Needs the `claude` binary + auth, and burns tokens, so it is **gated**
and never runs in normal lefthook/CI:

```sh
MECHANISM_PROBES=1 bats tests/mechanism/
```

Without `MECHANISM_PROBES=1` (or without `claude` on PATH) every probe
skips. `opencode` probes are added the same way once that binary is
available.

## What each probe asserts (the SPEC belief)

| probe | belief |
| ----- | ------ |
| skill auto-load | token **absent** -- skills are model-invoked, not always-on (B2) |
| path-less rule | token **present** -- loads always |
| path-scoped rule on read | **present** -- loads when reading a matching file |
| path-scoped rule on write | **present** -- expected, but write-trigger is the open G2 question |
| `@`-recursion in `CLAUDE.md` | **present** -- `@` resolves recursively (V29 compiler fidelity) |
| `@` inside a rule | **present** -- the open `@`-in-rules question |
| symlinked rule | **present** -- rules resolve symlinks |
| skill `disable-model-invocation` | **absent** -- not auto-loaded (dedup, V20) |

## Reading results

A **failing** probe is a **finding**: the SPEC belief is wrong. Per the
build flow, that triggers `/spec bug:` (backprop) and a channel-policy
correction -- not a blind code fix. Probes assert *behaviour* (the model
echoes the token), which is best-effort, not enforcement; re-run before
treating a single result as definitive.

### Method caveat (important)

Probes observe **behaviour**, and rules/skills are *context, not
enforced*. So "token absent" is ambiguous: the content may not have
**loaded**, or it loaded but the model did not **comply** with the
marker directive. An unconditional "always begin with TOKEN" marker is
especially prone to non-compliance on an unrelated prompt. Treat a
single negative as a hint, not proof; corroborate across runs and marker
styles.

### Findings (2026-06-26, claude 2.1.193, query-style + VOTES=3)

Method evolved across runs: directive markers ("always begin with X")
were compliance-noisy; switched to **query** markers (a secret
passphrase the model reports from loaded context) + **majority voting**
over N runs, since single runs are nondeterministic.

Confirmed (stable across voted runs):

- default `SKILL.md` is **NOT always-on** -- model-invokes only when the
  prompt matches its description.
- path-less rule **loads always**.
- **`@`-import recurses** through `CLAUDE.md` (V29 compiler fidelity).
- **`@`-import expands inside a rule** -> DRY `@`-referencing rules viable.
- **symlinked** rule loads.
- `disable-model-invocation: true` **blocks** auto-load (dedup works).

Inconclusive (skipped -- not reliably observable by probing):

- path-scoped rule **read-vs-write trigger**: verdict flips across voted
  runs (read NOTLOADED / write LOADED one run, reverse another). The
  mechanism itself is real -- path-scoped rules load live in this repo's
  dogfood (editing `.md` surfaces the markdown set-rules) -- but the
  precise trigger can't be pinned behaviourally. So **G2 stays open**;
  design defensively (write-critical rules -> broad/always-on globs).
