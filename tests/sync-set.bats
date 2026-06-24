#!/usr/bin/env bats

# Unit tests for set/lib/sync-set.sh -- copies the emitted set tree
# into a target directory with clean-replace semantics (V26).
# Covers both claude and opencode agent trees (V21/V23).

setup() {
    SRC="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/sync-set.sh"
    mkdir -p "$SRC/bin"
    cp "$SCRIPT" "$SRC/bin/sync-set"
    chmod +x "$SRC/bin/sync-set"
    mkdir -p "$SRC/.claude/rules/set/demo"
    echo "rule content" >"$SRC/.claude/rules/set/demo/sub.md"
}

teardown() {
    rm -rf "$SRC" "$TARGET"
}

@test "copies .claude/rules/set tree into explicit target" {
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced set"* ]]
    [ -f "$TARGET/.claude/rules/set/demo/sub.md" ]
    [ "$(cat "$TARGET/.claude/rules/set/demo/sub.md")" = "rule content" ]
}

@test "defaults to cwd when no target argument" {
    run bash -c "cd '$TARGET' && bash '$SRC/bin/sync-set'"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.claude/rules/set/demo/sub.md" ]
}

@test "succeeds when source has no agent dir" {
    rm -rf "$SRC/.claude"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced set"* ]]
}

@test "overwrites existing files on re-sync" {
    mkdir -p "$TARGET/.claude/rules/set/demo"
    echo "old" >"$TARGET/.claude/rules/set/demo/sub.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/.claude/rules/set/demo/sub.md")" = "rule content" ]
}

@test "clean-replace removes stale files from prior sync (V26)" {
    mkdir -p "$TARGET/.claude/rules/set/stale"
    echo "stale" >"$TARGET/.claude/rules/set/stale/old.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ ! -e "$TARGET/.claude/rules/set/stale" ]
    [ -f "$TARGET/.claude/rules/set/demo/sub.md" ]
}

@test "syncs opencode tree when source has .opencode (V23)" {
    rm -rf "$SRC/.claude"
    mkdir -p "$SRC/.opencode/rules/set/demo"
    echo "opencode rule" >"$SRC/.opencode/rules/set/demo/sub.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced set"* ]]
    [ -f "$TARGET/.opencode/rules/set/demo/sub.md" ]
    [ "$(cat "$TARGET/.opencode/rules/set/demo/sub.md")" = "opencode rule" ]
    [ ! -d "$TARGET/.claude" ]
}

@test "clean-replace works for opencode tree (V23/V26)" {
    rm -rf "$SRC/.claude"
    mkdir -p "$SRC/.opencode/rules/set/demo"
    echo "fresh" >"$SRC/.opencode/rules/set/demo/sub.md"
    mkdir -p "$TARGET/.opencode/rules/set/stale"
    echo "stale" >"$TARGET/.opencode/rules/set/stale/old.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ ! -e "$TARGET/.opencode/rules/set/stale" ]
    [ -f "$TARGET/.opencode/rules/set/demo/sub.md" ]
}
