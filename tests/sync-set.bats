#!/usr/bin/env bats

# Unit tests for set/lib/sync-set.sh -- copies the emitted set tree
# into a target directory with clean-replace semantics (V26).

setup() {
    SRC="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/sync-set.sh"
    mkdir -p "$SRC/bin"
    cp "$SCRIPT" "$SRC/bin/sync-set"
    chmod +x "$SRC/bin/sync-set"
    mkdir -p "$SRC/.claude/skills/set/demo"
    echo "skill content" >"$SRC/.claude/skills/set/demo/SKILL.md"
}

teardown() {
    rm -rf "$SRC" "$TARGET"
}

@test "copies .claude tree into explicit target" {
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced set"* ]]
    [ -f "$TARGET/.claude/skills/set/demo/SKILL.md" ]
    [ "$(cat "$TARGET/.claude/skills/set/demo/SKILL.md")" = "skill content" ]
}

@test "defaults to cwd when no target argument" {
    run bash -c "cd '$TARGET' && bash '$SRC/bin/sync-set'"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.claude/skills/set/demo/SKILL.md" ]
}

@test "succeeds when source has no .claude dir" {
    rm -rf "$SRC/.claude"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced set"* ]]
}

@test "overwrites existing files on re-sync" {
    mkdir -p "$TARGET/.claude/skills/set/demo"
    echo "old" >"$TARGET/.claude/skills/set/demo/SKILL.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/.claude/skills/set/demo/SKILL.md")" = "skill content" ]
}

@test "clean-replace removes stale files from prior sync (V26)" {
    mkdir -p "$TARGET/.claude/skills/set/stale"
    echo "stale" >"$TARGET/.claude/skills/set/stale/SKILL.md"
    echo "stale facet" >"$TARGET/.claude/skills/set/stale/old.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ ! -e "$TARGET/.claude/skills/set/stale" ]
    [ -f "$TARGET/.claude/skills/set/demo/SKILL.md" ]
}
