#!/usr/bin/env bats
# Unit coverage for lib/skill-size-check.sh -- enforce per-file size limit on
# individual skill/draft markdown (T57). Single wc -c check. Independent of
# format or structure checks.

setup() {
    bats_require_minimum_version 1.5.0
    ROOT="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/skill-size-check.sh"
    mkdir -p "$ROOT/set/skills/generic" "$ROOT/set/skills/nix" \
        "$ROOT/set/drafts/agent"
    printf '# generic\n' >"$ROOT/set/skills/generic/generic.md"
    printf '# nix\n' >"$ROOT/set/skills/nix/nix.md"
    printf '# agent\n' >"$ROOT/set/drafts/agent/anatomy.md"
}

teardown() {
    rm -rf "$ROOT"
    return 0
}

# --- all files within budget (green) ----------------------------------------

@test "small files pass with default limit" {
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all files in skills/ and drafts/ within"* ]]
}

@test "empty skills/ and drafts/ passes" {
    rm -rf "$ROOT/set/skills" "$ROOT/set/drafts"
    mkdir -p "$ROOT/set/skills" "$ROOT/set/drafts"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all files in skills/ and drafts/ within"* ]]
}

@test "missing drafts/ dir passes" {
    rm -rf "$ROOT/set/drafts"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all files in skills/ and drafts/ within"* ]]
}

@test "file exactly at limit passes" {
    SKILL_SIZE_LIMIT=100 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    dd if=/dev/zero bs=1 count=100 2>/dev/null | tr '\0' 'x' >"$ROOT/set/skills/generic/exact.md"
    SKILL_SIZE_LIMIT=100 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "nested subdirectories with small files pass" {
    mkdir -p "$ROOT/set/skills/nix/hardening"
    printf '# hardening\n' >"$ROOT/set/skills/nix/hardening/hardening.md"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

# --- oversized files fail (exit 1) -----------------------------------------

@test "file exceeding limit fails" {
    dd if=/dev/zero bs=1 count=101 2>/dev/null | tr '\0' 'x' >"$ROOT/set/skills/generic/big.md"
    SKILL_SIZE_LIMIT=100 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"big.md"* ]]
    [[ "$output" == *"101 bytes"* ]]
    [[ "$output" == *"limit: 100"* ]]
}

@test "oversized file in drafts/ fails" {
    dd if=/dev/zero bs=1 count=50 2>/dev/null | tr '\0' 'x' >"$ROOT/set/drafts/agent/big.md"
    SKILL_SIZE_LIMIT=40 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"big.md"* ]]
}

@test "oversized file in nested subdir fails" {
    mkdir -p "$ROOT/set/skills/nix/hardening"
    dd if=/dev/zero bs=1 count=200 2>/dev/null | tr '\0' 'x' >"$ROOT/set/skills/nix/hardening/big.md"
    SKILL_SIZE_LIMIT=100 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"big.md"* ]]
}

@test "multiple oversized files each get a FAIL line" {
    dd if=/dev/zero bs=1 count=101 2>/dev/null | tr '\0' 'x' >"$ROOT/set/skills/generic/a.md"
    dd if=/dev/zero bs=1 count=101 2>/dev/null | tr '\0' 'x' >"$ROOT/set/skills/nix/b.md"
    SKILL_SIZE_LIMIT=100 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    local count
    count="$(printf '%s\n' "$output" | grep -c 'FAIL')"
    [ "$count" -eq 2 ]
}

@test "oversized in both skills/ and drafts/ reports both" {
    dd if=/dev/zero bs=1 count=101 2>/dev/null | tr '\0' 'x' >"$ROOT/set/skills/generic/big-s.md"
    dd if=/dev/zero bs=1 count=101 2>/dev/null | tr '\0' 'x' >"$ROOT/set/drafts/agent/big-d.md"
    SKILL_SIZE_LIMIT=100 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"skills/"* ]]
    [[ "$output" == *"drafts/"* ]]
}

# --- custom limit -----------------------------------------------------------

@test "SKILL_SIZE_LIMIT overrides default" {
    dd if=/dev/zero bs=1 count=20 2>/dev/null | tr '\0' 'x' >"$ROOT/set/skills/generic/small.md"
    SKILL_SIZE_LIMIT=10 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"limit: 10"* ]]
}

@test "large limit allows big files" {
    dd if=/dev/zero bs=1 count=5000 2>/dev/null | tr '\0' 'x' >"$ROOT/set/skills/generic/big.md"
    SKILL_SIZE_LIMIT=10000 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

# --- non-md files are ignored -----------------------------------------------

@test "non-md files are not size-checked" {
    dd if=/dev/zero bs=1 count=10000 2>/dev/null | tr '\0' 'x' >"$ROOT/set/skills/generic/big.txt"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

# --- files outside skills/ and drafts/ are ignored --------------------------

@test "large file in set/ root is ignored" {
    dd if=/dev/zero bs=1 count=10000 2>/dev/null | tr '\0' 'x' >"$ROOT/set/big.md"
    SKILL_SIZE_LIMIT=100 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "large file in set/concepts/ is ignored" {
    mkdir -p "$ROOT/set/concepts"
    dd if=/dev/zero bs=1 count=10000 2>/dev/null | tr '\0' 'x' >"$ROOT/set/concepts/big.md"
    SKILL_SIZE_LIMIT=100 SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

# --- env guards -------------------------------------------------------------

@test "missing SET_ROOT fails fast" {
    run bash "$SCRIPT"
    [ "$status" -ne 0 ]
}
