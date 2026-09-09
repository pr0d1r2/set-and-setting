#!/usr/bin/env bats

# Unit tests for lib/canon-drift-check.sh -- the canonical-paths half extracted
# from mk-canon-drift-check.nix. Contract: every path named in REL_PATHS must
# exist under EXPECTED, because comparing against something absent proves
# nothing; an absent one is UNKNOWN (exit 1, carrying SYNC_HINT). When they all
# exist, the generic comparator at DRIFT_CHECK_SCRIPT decides, and its exit
# status is the check's.

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/canon-drift-check.sh"
    mkdir -p "$TMP/expected/docs"
    : >"$TMP/expected/docs/canon.md"
    printf '#!/usr/bin/env bash\necho "drift-check ran"\n' >"$TMP/drift.sh"
    export EXPECTED="$TMP/expected"
    export ACTUAL="$TMP/expected"
    export REL_PATHS="docs/canon.md"
    export SYNC_HINT="run: just canon-sync"
    export DRIFT_CHECK_SCRIPT="$TMP/drift.sh"
    export out="$TMP/out"
}

teardown() {
    rm -rf "$TMP"
}

@test "every pinned path present: the comparator runs and \$out is created" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"drift-check ran"* ]]
    [ -f "$TMP/out" ]
}

@test "an absent pinned path is UNKNOWN, names the path, and carries the hint" {
    rm "$TMP/expected/docs/canon.md"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"UNKNOWN"* ]]
    [[ "$output" == *"docs/canon.md"* ]]
    [[ "$output" == *"just canon-sync"* ]]
}

@test "an absent pinned path does not run the comparator" {
    rm "$TMP/expected/docs/canon.md"
    run bash "$SCRIPT"
    [[ "$output" != *"drift-check ran"* ]]
    [ ! -f "$TMP/out" ]
}

@test "several pinned paths: the FIRST absent one is the one reported" {
    export REL_PATHS="docs/canon.md docs/gone.md"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"docs/gone.md"* ]]
}

@test "an empty REL_PATHS is not an error -- the comparator still decides" {
    export REL_PATHS=""
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"drift-check ran"* ]]
}

@test "a failing comparator fails the check, and \$out is not created" {
    printf '#!/usr/bin/env bash\necho "drift found"\nexit 1\n' >"$TMP/drift.sh"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"drift found"* ]]
    [ ! -f "$TMP/out" ]
}
