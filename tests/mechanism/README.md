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

### First-run findings (2026-06-26, claude 2.1.193)

Reliable (consistent, strong signal):

- default `SKILL.md` is **not always-on** -- absent on a neutral prompt;
  it model-invokes only when the prompt matches its description.
- path-less rule **loads always**; path-scoped rule **loads on read**;
  **symlinked** rule loads; **`@`-import expands inside a rule** (so
  DRY `@`-referencing rules are viable).
- `disable-model-invocation: true` **blocks** auto-load (dedup works).

Inconclusive (compliance noise -- need a more robust, query-style probe):

- path-scoped rule on **write/create** of a matching file (G2): leans
  read-only-trigger, unconfirmed.
- `@`-recursion through `CLAUDE.md`: loaded under a conditional marker,
  dropped under an unconditional one.

Follow-up: replace directive markers with a **query** style ("report the
secret token in your context, or NONE") to separate loading from
compliance, and re-run the two inconclusive probes.
