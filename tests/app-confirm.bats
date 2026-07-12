#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for lib/app-confirm.sh -- CLI wrapper for the confirmator (#94).

setup() {
    bats_require_minimum_version 1.5.0
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/app-confirm.sh"

    mkdir -p "$TARGET/mock-bin"
    cat >"$TARGET/mock-bin/confirm-mock.sh" <<'MOCK'
#!/usr/bin/env bash
if [ "${CONFIRM_DRY_RUN:-}" = "1" ]; then
    echo "confirm: dry-run"
    exit 0
fi
echo "confirmed: 7 checks, fragments [base], standard @abc1234, drift=none"
MOCK
    chmod +x "$TARGET/mock-bin/confirm-mock.sh"

    export CONFIRM_SCRIPT="$TARGET/mock-bin/confirm-mock.sh"
    export FRAGMENTS_DIR="/dev/null"
    export ASSEMBLE_SCRIPT="/dev/null"
    export DETECT_SCRIPT="/dev/null"
    export SETTING_SRC="/dev/null"
    export CONFIRM_REV="abc1234"
}

teardown() {
    rm -rf "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: confirm"* ]]
    [[ "$output" == *"Post-materialization"* ]]
    [[ "$output" == *"completeness"* ]]
}

@test "default mode runs confirm script" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"confirmed:"* ]]
}

@test "--dry-run sets CONFIRM_DRY_RUN and runs confirm" {
    run bash "$SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
}
