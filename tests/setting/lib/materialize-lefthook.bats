#!/usr/bin/env bats

# Unit tests for setting/lib/materialize-lefthook.sh -- the assemble-then-overlay
# step extracted from mk-materialization.nix. Contract: assemble ALWAYS runs;
# the migration overlay runs only when the caller supplied one, which is the
# `if hasMigrations && …` that used to live in Nix, expressed as a shell test
# over the variables the derivation already exports.

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../../setting/lib/materialize-lefthook.sh"
    LOG="$TMP/calls"
    : >"$LOG"
    printf '#!/usr/bin/env bash\necho assemble >> %q\n' "$LOG" >"$TMP/assemble.sh"
    printf '#!/usr/bin/env bash\necho overlay >> %q\n' "$LOG" >"$TMP/overlay.sh"
    mkdir -p "$TMP/overlay-dir"
    export ASSEMBLE_SCRIPT="$TMP/assemble.sh"
    export MIGRATION_HAS_OVERLAY=""
    export MIGRATION_OVERLAY_DIR=""
    export MIGRATION_OVERLAY_SCRIPT=""
}

teardown() {
    rm -rf "$TMP"
}

overlay_supplied() {
    export MIGRATION_HAS_OVERLAY=1
    export MIGRATION_OVERLAY_DIR="$TMP/overlay-dir"
    export MIGRATION_OVERLAY_SCRIPT="$TMP/overlay.sh"
}

@test "no overlay supplied: assemble runs alone" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [ "$output" = "assemble" ]
}

@test "an overlay supplied: assemble runs FIRST, then the overlay" {
    overlay_supplied
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [ "${lines[0]}" = "assemble" ]
    [ "${lines[1]}" = "overlay" ]
}

@test "the flag alone is not enough -- an unset overlay script skips it" {
    overlay_supplied
    export MIGRATION_OVERLAY_SCRIPT=""
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [ "$output" = "assemble" ]
}

@test "the scripts alone are not enough -- an unset flag skips the overlay" {
    overlay_supplied
    export MIGRATION_HAS_OVERLAY=""
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [ "$output" = "assemble" ]
}

@test "a failing assemble fails the step and never reaches the overlay" {
    overlay_supplied
    printf '#!/usr/bin/env bash\nexit 1\n' >"$TMP/assemble.sh"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    run cat "$LOG"
    [ "$output" = "" ]
}

@test "a failing overlay fails the step" {
    overlay_supplied
    printf '#!/usr/bin/env bash\nexit 1\n' >"$TMP/overlay.sh"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
}
