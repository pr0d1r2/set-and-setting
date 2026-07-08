#!/usr/bin/env bats

# Unit tests for set/lib/sync-set.sh -- copies the emitted set tree
# into a target directory with clean-replace semantics (V26).
# Covers claude, opencode, and caveman-code agent trees (V21/V23).

setup() {
    bats_require_minimum_version 1.5.0
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
    chmod -R u+w "$SRC" "$TARGET" 2>/dev/null || true
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

@test "re-syncs over a read-only tree from a prior store copy (B4)" {
    # Simulate a prior sync that cp'd from /nix/store: tree is read-only,
    # so the clean-replace rm would fail without a chmod u+w first.
    mkdir -p "$TARGET/.claude/rules/set/stale"
    echo "stale" >"$TARGET/.claude/rules/set/stale/old.md"
    chmod -R a-w "$TARGET/.claude/rules/set"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ ! -e "$TARGET/.claude/rules/set/stale" ]
    [ -f "$TARGET/.claude/rules/set/demo/sub.md" ]
}

@test "emitted tree is writable even when source is read-only (B4)" {
    # Mimic the /nix/store source: read-only. cp -r would carry those
    # perms to the target without the post-copy chmod u+w.
    chmod -R a-w "$SRC/.claude/rules/set"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ -w "$TARGET/.claude/rules/set" ]
    [ -w "$TARGET/.claude/rules/set/demo/sub.md" ]
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

@test "syncs caveman-code tree when source has .cave (V23)" {
    rm -rf "$SRC/.claude"
    mkdir -p "$SRC/.cave/rules/set/demo"
    echo "cave rule" >"$SRC/.cave/rules/set/demo/sub.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced set"* ]]
    [ -f "$TARGET/.cave/rules/set/demo/sub.md" ]
    [ "$(cat "$TARGET/.cave/rules/set/demo/sub.md")" = "cave rule" ]
    [ ! -d "$TARGET/.claude" ]
}

@test "clean-replace works for caveman-code tree (V23/V26)" {
    rm -rf "$SRC/.claude"
    mkdir -p "$SRC/.cave/rules/set/demo"
    echo "fresh" >"$SRC/.cave/rules/set/demo/sub.md"
    mkdir -p "$TARGET/.cave/rules/set/stale"
    echo "stale" >"$TARGET/.cave/rules/set/stale/old.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ ! -e "$TARGET/.cave/rules/set/stale" ]
    [ -f "$TARGET/.cave/rules/set/demo/sub.md" ]
}

@test "rename propagation reports renames during sync (T24)" {
    # Set up a rename map in the source derivation
    printf 'demo/sub.md|demo/new-sub.md\n' >"$SRC/.claude/rules/set/.mkset-renames"
    mkdir -p "$SRC/bin"
    cp "$BATS_TEST_DIRNAME/../set/lib/rename-propagate.sh" "$SRC/bin/rename-propagate"
    chmod +x "$SRC/bin/rename-propagate"
    # Set up an old manifest in the target referencing the old path
    mkdir -p "$TARGET/.claude/rules/set"
    printf '{"categories":["demo"],"rev":"old","agent":"claude","applicability":{"demo/sub.md":"core"}}\n' \
        >"$TARGET/.claude/rules/set/.mkset.json"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"demo/sub.md -> demo/new-sub.md"* ]]
    [[ "$output" == *"synced set"* ]]
}

@test "sync succeeds without rename propagation files (T24)" {
    # Source has no .mkset-renames -- graceful no-op
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced set"* ]]
    [ -f "$TARGET/.claude/rules/set/demo/sub.md" ]
}

# --- T44: portable SKILL.md channel (V20) ---

@test "syncs SKILL.md files from .claude/skills (T44/V20)" {
    mkdir -p "$SRC/.claude/skills/set-demo"
    printf '%s\n' "---" "name: set-demo" "---" "# demo" >"$SRC/.claude/skills/set-demo/SKILL.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.claude/skills/set-demo/SKILL.md" ]
    grep -q 'name: set-demo' "$TARGET/.claude/skills/set-demo/SKILL.md"
}

@test "clean-replaces stale SKILL.md dirs on re-sync (T44/V26)" {
    mkdir -p "$SRC/.claude/skills/set-demo"
    echo "fresh" >"$SRC/.claude/skills/set-demo/SKILL.md"
    mkdir -p "$TARGET/.claude/skills/set-stale"
    echo "stale" >"$TARGET/.claude/skills/set-stale/SKILL.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ ! -e "$TARGET/.claude/skills/set-stale" ]
    [ -f "$TARGET/.claude/skills/set-demo/SKILL.md" ]
}

@test "SKILL.md writable even from read-only source (T44/B4)" {
    mkdir -p "$SRC/.claude/skills/set-demo"
    echo "content" >"$SRC/.claude/skills/set-demo/SKILL.md"
    chmod -R a-w "$SRC/.claude/skills"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ -w "$TARGET/.claude/skills/set-demo/SKILL.md" ]
}

@test "no SKILL.md sync when none in source (T44)" {
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ ! -d "$TARGET/.claude/skills" ]
}

# --- T44: AGENTS.md compilation (V29) ---

@test "compiles set.md into AGENTS.md at target root (T44/V29)" {
    # Create an always-on core rule (no frontmatter)
    echo "always-on core content" >"$SRC/.claude/rules/set/demo/sub.md"
    # Create the @-manifest referencing it
    printf '# Set\n\n@set/demo/sub.md\n' >"$SRC/.claude/rules/set.md"
    # Ship the compiler
    cp "$BATS_TEST_DIRNAME/../lib/agents-md-compile.sh" "$SRC/bin/agents-md-compile"
    chmod +x "$SRC/bin/agents-md-compile"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/AGENTS.md" ]
    grep -q 'always-on core content' "$TARGET/AGENTS.md"
}

@test "AGENTS.md not created when compiler absent (T44)" {
    printf '# Set\n\n@set/demo/sub.md\n' >"$SRC/.claude/rules/set.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    [ ! -f "$TARGET/AGENTS.md" ]
}

@test "AGENTS.md overwrites on re-sync (T44/V29)" {
    echo "always-on" >"$SRC/.claude/rules/set/demo/sub.md"
    printf '# Set\n\n@set/demo/sub.md\n' >"$SRC/.claude/rules/set.md"
    cp "$BATS_TEST_DIRNAME/../lib/agents-md-compile.sh" "$SRC/bin/agents-md-compile"
    chmod +x "$SRC/bin/agents-md-compile"
    echo "old" >"$TARGET/AGENTS.md"
    run bash "$SRC/bin/sync-set" "$TARGET"
    [ "$status" -eq 0 ]
    grep -q 'always-on' "$TARGET/AGENTS.md"
    run ! grep -q 'old' "$TARGET/AGENTS.md"
}
