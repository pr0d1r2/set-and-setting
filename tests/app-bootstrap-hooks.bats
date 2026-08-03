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

@test "fails outside a git repository" {
    cd "$TARGET"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not a git repository"* ]]
}

@test "rejects unknown arguments" {
    cd "$TARGET"
    run bash "$SCRIPT" --bad
    [ "$status" -eq 2 ]
}
