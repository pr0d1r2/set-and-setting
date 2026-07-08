#!/usr/bin/env bats
# Unit coverage for lib/skill-extension-check.sh -- enforce V6/V13: only
# *.md files in set/skills/ and set/drafts/ (T56). Pure find + exit-on-non-md.
# No content parsing.

setup() {
    bats_require_minimum_version 1.5.0
    ROOT="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/skill-extension-check.sh"
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

# --- all *.md passes (green) ----------------------------------------------

@test "tree with only .md files passes" {
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all files in skills/ and drafts/ are *.md"* ]]
}

@test "empty skills/ and drafts/ passes" {
    rm -rf "$ROOT/set/skills" "$ROOT/set/drafts"
    mkdir -p "$ROOT/set/skills" "$ROOT/set/drafts"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all files in skills/ and drafts/ are *.md"* ]]
}

@test "missing drafts/ dir passes" {
    rm -rf "$ROOT/set/drafts"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all files in skills/ and drafts/ are *.md"* ]]
}

@test "nested subdirectories with only .md files pass" {
    mkdir -p "$ROOT/set/skills/nix/hardening"
    printf '# hardening\n' >"$ROOT/set/skills/nix/hardening/hardening.md"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

# --- non-md files fail (exit 1) -------------------------------------------

@test ".txt file in skills/ fails" {
    printf 'notes\n' >"$ROOT/set/skills/generic/notes.txt"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"notes.txt"* ]]
}

@test ".sh file in skills/ fails" {
    printf '#!/bin/bash\n' >"$ROOT/set/skills/nix/helper.sh"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"helper.sh"* ]]
}

@test ".nix file in skills/ fails" {
    printf '{ }\n' >"$ROOT/set/skills/nix/config.nix"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"config.nix"* ]]
}

@test "non-md file in drafts/ fails" {
    printf 'draft\n' >"$ROOT/set/drafts/agent/scratch.txt"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"scratch.txt"* ]]
}

@test "non-md file in nested subdir fails" {
    mkdir -p "$ROOT/set/skills/nix/hardening"
    printf '{ }\n' >"$ROOT/set/skills/nix/hardening/data.json"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"data.json"* ]]
}

@test "multiple non-md files each get a FAIL line" {
    printf 'a\n' >"$ROOT/set/skills/generic/a.txt"
    printf 'b\n' >"$ROOT/set/skills/nix/b.sh"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    local count
    count="$(printf '%s\n' "$output" | grep -c 'FAIL')"
    [ "$count" -eq 2 ]
}

@test "FAIL line names the subdir (skills/ or drafts/)" {
    printf 'x\n' >"$ROOT/set/drafts/agent/x.yml"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"in drafts/"* ]]
}

@test "non-md in both skills/ and drafts/ fails with both reported" {
    printf 'a\n' >"$ROOT/set/skills/generic/a.txt"
    printf 'b\n' >"$ROOT/set/drafts/agent/b.yml"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"in skills/"* ]]
    [[ "$output" == *"in drafts/"* ]]
}

# --- files outside skills/ and drafts/ are ignored ------------------------

@test "non-md file in set/ root is ignored" {
    printf '{ }\n' >"$ROOT/set/meta.nix"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "non-md file in set/concepts/ is ignored" {
    mkdir -p "$ROOT/set/concepts"
    printf '{ }\n' >"$ROOT/set/concepts/data.nix"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "non-md file in set/lib/ is ignored" {
    mkdir -p "$ROOT/set/lib"
    printf '#!/bin/bash\n' >"$ROOT/set/lib/helper.sh"
    SET_ROOT="$ROOT/set" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

# --- env guards -----------------------------------------------------------

@test "missing SET_ROOT fails fast" {
    run bash "$SCRIPT"
    [ "$status" -ne 0 ]
}
