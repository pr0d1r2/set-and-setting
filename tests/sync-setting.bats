#!/usr/bin/env bats

# Unit tests for setting/lib/sync-setting.sh -- copies materialized
# configs into a target directory, always overwriting.

setup() {
    SRC="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/sync-setting.sh"
    WRAPPER="$(mktemp)"
    printf 'src="%s"\n' "$SRC" >"$WRAPPER"
    cat "$SCRIPT" >>"$WRAPPER"
    echo "markdownlint config" >"$SRC/.markdownlint.yml"
    echo "yamllint config" >"$SRC/.yamllint.yml"
}

teardown() {
    rm -rf "$SRC" "$TARGET" "$WRAPPER"
}

@test "copies materialized files into explicit target" {
    run bash "$WRAPPER" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced setting"* ]]
    [ -f "$TARGET/.markdownlint.yml" ]
    [ "$(cat "$TARGET/.markdownlint.yml")" = "markdownlint config" ]
    [ -f "$TARGET/.yamllint.yml" ]
    [ "$(cat "$TARGET/.yamllint.yml")" = "yamllint config" ]
}

@test "defaults to cwd when no target argument" {
    run bash -c "cd '$TARGET' && bash '$WRAPPER'"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.markdownlint.yml" ]
    [ -f "$TARGET/.yamllint.yml" ]
}

@test "overwrites existing files on re-sync" {
    echo "old" >"$TARGET/.markdownlint.yml"
    run bash "$WRAPPER" "$TARGET"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/.markdownlint.yml")" = "markdownlint config" ]
}

@test "creates parent directories for nested files" {
    mkdir -p "$SRC/.claude/commands"
    echo "cmd" >"$SRC/.claude/commands/test.md"
    printf 'src="%s"\n' "$SRC" >"$WRAPPER"
    cat "$SCRIPT" >>"$WRAPPER"
    run bash "$WRAPPER" "$TARGET"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.claude/commands/test.md" ]
}

@test "succeeds when source has no files" {
    rm -f "$SRC/.markdownlint.yml" "$SRC/.yamllint.yml"
    run bash "$WRAPPER" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced setting"* ]]
}
