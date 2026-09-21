#!/usr/bin/env bats

# Unit tests for lib/lefthook-check.sh -- the runner extracted from
# mk-lefthook-check.nix. Contract: run CHECK_WRAPPER with CHECK_FLAG over every
# file found under CHECK_FILES; an EMPTY tree is a PASS, because `suffices`
# filtering can legitimately select nothing and a linter with no input has
# nothing to say about the code.

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/lefthook-check.sh"
    mkdir -p "$TMP/files/sub"
    : >"$TMP/files/a.rb"
    : >"$TMP/files/sub/b.rb"
    ARGS="$TMP/args"
    printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$@" > %q\n' "$ARGS" >"$TMP/wrapper"
    chmod +x "$TMP/wrapper"
    export CHECK_NAME="rubocop"
    export CHECK_FILES="$TMP/files"
    export CHECK_WRAPPER="$TMP/wrapper"
    export CHECK_FLAG="--lint"
    export out="$TMP/out"
}

teardown() {
    rm -rf "$TMP"
}

@test "a populated tree passes, reports the file count, and creates \$out" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"rubocop: PASS (2 files)"* ]]
    [ -f "$TMP/out" ]
}

@test "the wrapper is called with CHECK_FLAG first, then every file" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run head -1 "$TMP/args"
    [ "$output" = "--lint" ]
    run grep -c '^\./' "$TMP/args"
    [ "$output" = "2" ]
}

@test "an EMPTY tree is a pass that says so and never calls the wrapper" {
    rm -rf "$TMP/files"
    mkdir -p "$TMP/files"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"no matching files, nothing to check"* ]]
    [ -f "$TMP/out" ]
    [ ! -f "$TMP/args" ]
}

@test "a refusing wrapper fails the check, and \$out is not created" {
    printf '#!/usr/bin/env bash\necho "offence found" >&2\nexit 1\n' >"$TMP/wrapper"
    chmod +x "$TMP/wrapper"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [ ! -f "$TMP/out" ]
}

@test "the file list is sorted, so the wrapper sees a stable order" {
    : >"$TMP/files/aaa.rb"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run env LC_ALL=C sort -c "$TMP/args"
    [ "$status" -eq 0 ]
}
