#!/usr/bin/env bats
# Unit coverage for lib/ref-resolve-check.sh -- the ref-resolution check
# (T64). Consumes the T63 matcher (lib/ref-match.sh) and resolves each real
# @-reference to an existing path under set/: @set/... from the repo root,
# relative @<cat>/<file>.md against its own dir/parent (drafts vs skills).
# Exit 1 ONLY on a truly-missing target; false-positive @ tokens the matcher
# skips must never fail the check.
# shellcheck disable=SC2030,SC2031,SC2016  # single-quoted @refs are literals

setup() {
    bats_require_minimum_version 1.5.0
    ROOT="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/ref-resolve-check.sh"
    MATCH="$BATS_TEST_DIRNAME/../lib/ref-match.sh"
    # A minimal set/ tree mirroring the real layout.
    mkdir -p "$ROOT/set/skills/language" "$ROOT/set/skills/git" \
        "$ROOT/set/drafts/agent" "$ROOT/set/concepts/hardware/apple"
    printf '# active\n' >"$ROOT/set/skills/language/active.md"
    printf '# narrow\n' >"$ROOT/set/skills/language/narrow.md"
    printf '# commit\n' >"$ROOT/set/skills/git/commit.md"
    printf '# anatomy\n' >"$ROOT/set/drafts/agent/anatomy.md"
    printf '# m4\n' >"$ROOT/set/concepts/hardware/apple/m4.md"
}

teardown() {
    rm -rf "$ROOT"
    return 0
}

# --- existing refs resolve (green) -------------------------------------

@test "relative @<cat>/<file>.md resolves against the sibling category" {
    printf '# Language\n\n@language/active.md\n@language/narrow.md\n' \
        >"$ROOT/set/skills/language/language.md"
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all @-references resolve"* ]]
}

@test "@set/ ref resolves from the repo root" {
    printf '# Bundle\n\n@set/skills/git/commit.md\n' \
        >"$ROOT/set/skills/git/bundle.md"
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "@set/drafts/ ref resolves (drafts vs skills)" {
    printf '# Agent\n\n@set/drafts/agent/anatomy.md\n' \
        >"$ROOT/set/drafts/agent/agent.md"
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "@set/concepts/ ref resolves" {
    printf '# HW\n\n@set/concepts/hardware/apple/m4.md\n' \
        >"$ROOT/set/concepts/hardware.md"
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "a tree with no @-refs passes" {
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all @-references resolve"* ]]
}

# --- truly-missing targets fail (exit 1) -------------------------------

@test "unresolved @set/ ref fails with exit 1" {
    printf '# Bad\n\n@set/skills/git/nope.md\n' \
        >"$ROOT/set/skills/git/bad.md"
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"@set/skills/git/nope.md"* ]]
}

@test "unresolved relative ref fails with exit 1" {
    printf '# Language\n\n@language/gone.md\n' \
        >"$ROOT/set/skills/language/language.md"
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"@language/gone.md"* ]]
}

@test "FAIL line names the referencing file" {
    printf '# Bad\n\n@set/skills/git/nope.md\n' \
        >"$ROOT/set/skills/git/bad.md"
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"set/skills/git/bad.md"* ]]
}

# --- false positives the matcher skips never fail the check ------------

@test "email / git SHA / prose @tokens do not fail resolution" {
    cat >"$ROOT/set/skills/git/prose.md" <<'EOF'
# Prose

Contact user@example.com. Pin owner/action@fbeb9d9. Tags like @main and
@v4 are mutable; awk lacks @include support.
EOF
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all @-references resolve"* ]]
}

@test "ref inside a code span or fence does not fail resolution" {
    cat >"$ROOT/set/skills/git/span.md" <<'EOF'
# Span

The `@language/does-not-exist.md` token is illustrative.

```
@set/skills/git/also-not-real.md
```
EOF
    SET_ROOT="$ROOT/set" REF_MATCH="$MATCH" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
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
