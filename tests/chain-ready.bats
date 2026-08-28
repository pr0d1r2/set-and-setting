#!/usr/bin/env bats

setup() {
    bats_require_minimum_version 1.5.0
    ROOT="$BATS_TEST_DIRNAME/.."
    SCRIPT="$ROOT/lib/chain-ready.sh"
    TARGET="$(mktemp -d)"
    BIN="$TARGET/bin"
    mkdir -p "$BIN"
    git -C "$TARGET" init -q --initial-branch=main
    git -C "$TARGET" config user.email test@test.com
    git -C "$TARGET" config user.name Test
    git -C "$TARGET" remote add origin https://github.com/owner/repo.git
    git -C "$TARGET" commit -q --allow-empty -m init
    export PATH="$BIN:$PATH"
}

teardown() {
    rm -rf "$TARGET"
}

write_fixture() {
    printf '%s\n' "$1" >"$TARGET/issues.json"
    printf '%s\n' '#!/usr/bin/env bash' 'cat "$ISSUES_JSON"' >"$BIN/gh"
    chmod +x "$BIN/gh"
    export ISSUES_JSON="$TARGET/issues.json"
}

@test "issues without dependencies and with closed dependencies are ready" {
    write_fixture '[
        {"number":291,"state":"CLOSED","stateReason":"COMPLETED","body":""},
        {"number":292,"state":"OPEN","stateReason":null,"body":"Depends on: #291"},
        {"number":293,"state":"OPEN","stateReason":null,"body":"No dependency"},
        {"number":294,"state":"OPEN","stateReason":null,"body":"Depends-on: owner/repo#292"}
    ]'
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ "$output" = $'292\n293' ]
}

@test "not planned closure does not satisfy a dependency" {
    write_fixture '[
        {"number":291,"state":"CLOSED","stateReason":"NOT_PLANNED","body":""},
        {"number":292,"state":"OPEN","stateReason":null,"body":"Depends on: #291"}
    ]'
    run bash -c "cd '$TARGET' && bash '$SCRIPT' 2>stderr"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    grep -q 'blocked by #291' "$TARGET/stderr"
}

@test "missing dependency is reported and not treated as ready" {
    write_fixture '[{"number":301,"state":"OPEN","stateReason":null,"body":"Depends on: #999"}]'
    run bash -c "cd '$TARGET' && bash '$SCRIPT' 2>stderr"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    grep -q 'missing issue #999' "$TARGET/stderr"
}

@test "cross repository dependency is reported and both dependency syntaxes parse" {
    write_fixture '[
        {"number":301,"state":"OPEN","stateReason":null,"body":"Depends on: #302"},
        {"number":302,"state":"OPEN","stateReason":null,"body":"Depends-on: other/repo#303"},
        {"number":304,"state":"OPEN","stateReason":null,"body":""}
    ]'
    run bash -c "cd '$TARGET' && bash '$SCRIPT' 2>stderr"
    [ "$status" -eq 0 ]
    [ "$output" = "304" ]
    grep -q 'another repository' "$TARGET/stderr"
}
