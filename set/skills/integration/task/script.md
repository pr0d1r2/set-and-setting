# Integration: task verification script

A task verification script is a self-contained, executable proof that
one task's SPEC claims hold. Pure shell plus the repo's own build and
test tooling. Every claim is checked by running the thing, not by
reading it.

## When to generate

Generate the script in the final phase of the task's PR -- after the
code is green, before merge. The script is the closing proof: red
blocks the merge gate, green is the evidence. Attach it to the phase
summary as an artifact.

## Contract

- Executable from repo root, no arguments required.
- Deterministic: same repo state produces same verdict.
- No hardcoded store paths, temp dirs, or user-specific state.
- Exit code equals the number of failures (0 = all pass).
- Every claim cites its SPEC id in the label (e.g. `V18`, `I.mkSet`).
- Each claim builds or derives the real artifact, diffs or greps
  observable output, or runs the guard suite.

## Shape

One `check` helper accumulates pass/fail. Each call proves one claim.

```sh
#!/usr/bin/env bash
# verify-<taskid>.sh -- reproducible verification of <task description>.
# Runs from repo root. Proves each SPEC claim by executing it.
set -uo pipefail

pass=0
fail=0

check() {
    if [ "$2" -eq 0 ]; then
        printf '  PASS  %s\n' "$1"
        pass=$((pass + 1))
    else
        printf '  FAIL  %s\n' "$1"
        fail=$((fail + 1))
    fi
}

echo "== <Tnn> <task title> verification =="

# <Vnn>: <what the invariant requires>
<command that tests the claim>
check "<Vnn> <short evidence label>" $?

# ... one check() per SPEC claim ...

echo "== $pass passed, $fail failed =="
exit "$fail"
```

## Claim patterns

Build the artifact then inspect it:

```sh
out=$(nix build ".#packages.$sys.set" --no-link --print-out-paths | tail -1)
[ -f "$out/expected/path.md" ]
check "V25 rule file emitted" $?
```

Diff emitted output against source:

```sh
diff -q "$emitted_body" "$source_file" >/dev/null
check "V18 emitted body byte-identical to source" $?
```

Run the project's own check suite:

```sh
nix flake check --no-build >/dev/null 2>&1
check "V1 nix flake check passes" $?
```

Grep for structural properties:

```sh
grep -q '^paths:' "$rule_file"
check "V18 rule has paths frontmatter" $?
```

Verify absence (excluded files, deprecated artifacts):

```sh
! find "$output_dir" -name 'SKILL.md' | grep -q .
check "V17 no SKILL.md in output" $?
```

## Naming

`verify-<taskid>.sh` where `<taskid>` is the lowercase task identifier
from the SPEC task table (e.g. `verify-t30.sh`, `verify-t40.sh`).

## Output format

```text
== T30 dogfood verification (x86_64-linux) ==
  PASS  V10 .claude/rules/set gitignored
  PASS  V18 rule = paths frontmatter + verbatim body
  FAIL  V26 sync-set wipes namespace before copy
== 1 passed, 1 failed ==
```

The table is human-readable and machine-parseable: grep for `FAIL` to
find broken claims, count lines for coverage.
