#!/usr/bin/env bats
# Unit coverage for lib/bundle-content-check.sh -- V12 bundle own-content
# enforcement (T65). A bundle is a file the T63 matcher finds a real @-ref
# in; its own content is limited to one heading + a purpose statement + the
# refs. Structural markdown (fenced code, lists, tables, blockquotes) and a
# second heading fail with exit 1. Ships independent of ref resolution (T64):
# a truly-missing ref target must NOT fail this check.
# shellcheck disable=SC2030,SC2031,SC2016  # single-quoted @refs/backticks are literals

setup() {
    bats_require_minimum_version 1.5.0
    ROOT="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/bundle-content-check.sh"
    MATCH="$BATS_TEST_DIRNAME/../lib/ref-match.sh"
    mkdir -p "$ROOT/set/skills/language"
}

teardown() {
    rm -rf "$ROOT"
    return 0
}

run_check() {
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
}

# --- well-formed bundles pass (green) ----------------------------------

@test "heading + purpose + refs passes" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Language

Language conventions for all written content in this repo.

@language/narrow.md
@language/active.md
EOF
    run_check
    [ "$status" -eq 0 ]
    [[ "$output" == *"limit own content"* ]]
}

@test "multi-line purpose statement passes" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Hardware

Hardware templates describe machine capabilities for development,
building, and testing. Each template is a standalone file under
`hardware/<vendor>/<model>.md`.

Consumer projects compose hardware into roles in their own concepts.

@set/concepts/hardware/apple/m4.md
EOF
    run_check
    [ "$status" -eq 0 ]
}

@test "inline code span in the purpose statement is allowed" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

The `<vendor>/<model>.md` layout is illustrative.

@language/active.md
EOF
    run_check
    [ "$status" -eq 0 ]
}

@test "a tree with no bundles passes" {
    printf '# active\n\nPlain prose, no refs.\n' \
        >"$ROOT/set/skills/language/active.md"
    run_check
    [ "$status" -eq 0 ]
    [[ "$output" == *"limit own content"* ]]
}

@test "an unresolved ref does not fail this check (resolution is T64)" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

@language/does-not-exist.md
EOF
    run_check
    [ "$status" -eq 0 ]
}

@test "prose file with false-positive @tokens is not treated as a bundle" {
    cat >"$ROOT/set/skills/language/prose.md" <<'EOF'
# Prose

Contact user@example.com. Pin owner/action@fbeb9d9. Tags like @main are
mutable; awk lacks @include support.

- a bullet list is fine here since this is not a bundle
EOF
    run_check
    [ "$status" -eq 0 ]
}

# --- structural own-content fails (exit 1) -----------------------------

@test "fenced code block fails" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

```
example code
```

@language/active.md
EOF
    run_check
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"fenced code"* ]]
}

@test "a fenced block reports once, not per body line" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

```
line one
line two
line three
```

@language/active.md
EOF
    run_check
    [ "$status" -eq 1 ]
    [ "$(printf '%s\n' "$output" | grep -c 'fenced code')" -eq 1 ]
}

@test "bullet list item fails" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

- an atomic point
@language/active.md
EOF
    run_check
    [ "$status" -eq 1 ]
    [[ "$output" == *"list item"* ]]
}

@test "ref dressed as a bullet fails (refs are bare @ lines)" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

@language/active.md
- @language/narrow.md
EOF
    run_check
    [ "$status" -eq 1 ]
    [[ "$output" == *"list item"* ]]
}

@test "ordered list item fails" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

1. an atomic step
@language/active.md
EOF
    run_check
    [ "$status" -eq 1 ]
    [[ "$output" == *"ordered list"* ]]
}

@test "table row fails" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

| a | b |
@language/active.md
EOF
    run_check
    [ "$status" -eq 1 ]
    [[ "$output" == *"table row"* ]]
}

@test "blockquote fails" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

> a quoted note
@language/active.md
EOF
    run_check
    [ "$status" -eq 1 ]
    [[ "$output" == *"blockquote"* ]]
}

@test "a second heading fails" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

## Section

@language/active.md
EOF
    run_check
    [ "$status" -eq 1 ]
    [[ "$output" == *"heading"* ]]
}

@test "FAIL line names the offending file and line number" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

| x |
@language/active.md
EOF
    run_check
    [ "$status" -eq 1 ]
    [[ "$output" == *"skills/language/language.md:5"* ]]
}

@test "structural content inside a code fence does not double-report" {
    cat >"$ROOT/set/skills/language/language.md" <<'EOF'
# Bundle

Purpose.

```
- not a real list
| not a real table
```

@language/active.md
EOF
    run_check
    [ "$status" -eq 1 ]
    [ "$(printf '%s\n' "$output" | grep -c FAIL)" -eq 1 ]
}

# --- env guards --------------------------------------------------------

@test "missing SET_ROOT fails fast" {
    REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -ne 0 ]
}

@test "missing REF_MATCH fails fast" {
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -ne 0 ]
}
