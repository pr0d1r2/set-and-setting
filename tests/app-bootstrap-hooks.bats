#!/usr/bin/env bats

setup() {
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/app-bootstrap-hooks.sh"
    mkdir -p "$TARGET/mock-bin"
    cat >"$TARGET/mock-bin/lefthook" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >"$LEFTHOOK_ARGS"
MOCK
    chmod +x "$TARGET/mock-bin/lefthook"
    export LEFTHOOK_ARGS="$TARGET/lefthook-args"
    export PATH="$TARGET/mock-bin:$PATH"
}

teardown() {
    rm -rf "$TARGET"
}

@test "installs hooks in a git repository" {
    git -C "$TARGET" init --quiet
    cd "$TARGET"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$LEFTHOOK_ARGS")" = "install" ]
}

@test "defers outside a git repository" {
    cd "$TARGET"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"deferred (not a git repository)"* ]]
    [ ! -e "$LEFTHOOK_ARGS" ]
}

@test "installs hooks in a linked git worktree" {
    local source="$TARGET/source"
    local worktree="$TARGET/worktree"
    git init --quiet "$source"
    git -C "$source" -c user.name=test -c user.email=test@example.com \
        commit --quiet --allow-empty -m initial
    git -C "$source" worktree add --quiet "$worktree"
    cd "$worktree"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$LEFTHOOK_ARGS")" = "install" ]
}

@test "rejects unknown arguments" {
    cd "$TARGET"
    run bash "$SCRIPT" --bad
    [ "$status" -eq 2 ]
}
