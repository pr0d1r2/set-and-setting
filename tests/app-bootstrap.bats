#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for set/lib/app-bootstrap.sh -- combined installer that
# runs mkSet core + mkSetting + mkSetting-init in sequence.

setup() {
    bats_require_minimum_version 1.5.0
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/app-bootstrap.sh"

    mkdir -p "$TARGET/mock-bin"
    cat >"$TARGET/mock-bin/mkSet" <<'MOCK'
#!/usr/bin/env bash
[ "${1:-}" = "--dry-run" ] && echo "mkSet: dry-run" && exit 0
echo "mkSet: installed"
MOCK
    cat >"$TARGET/mock-bin/mkSetting" <<'MOCK'
#!/usr/bin/env bash
[ "${1:-}" = "--dry-run" ] && echo "mkSetting: dry-run" && exit 0
echo "mkSetting: installed"
MOCK
    cat >"$TARGET/mock-bin/mkSetting-init" <<'MOCK'
#!/usr/bin/env bash
[ "${1:-}" = "--dry-run" ] && echo "mkSetting-init: dry-run" && exit 0
echo "mkSetting-init: installed"
MOCK
    chmod +x "$TARGET/mock-bin/mkSet" "$TARGET/mock-bin/mkSetting" "$TARGET/mock-bin/mkSetting-init"

    export MKSET_APP="$TARGET/mock-bin/mkSet"
    export MKSETTING_APP="$TARGET/mock-bin/mkSetting"
    export MKSETTING_INIT_APP="$TARGET/mock-bin/mkSetting-init"
}

teardown() {
    rm -rf "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: bootstrap"* ]]
    [[ "$output" == *"mkSet"* ]]
}

@test "default mode calls all three sub-apps" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"mkSet: installed"* ]]
    [[ "$output" == *"mkSetting: installed"* ]]
    [[ "$output" == *"mkSetting-init: installed"* ]]
}

@test "--dry-run passes through to all sub-apps" {
    run bash "$SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"mkSet: dry-run"* ]]
    [[ "$output" == *"mkSetting: dry-run"* ]]
    [[ "$output" == *"mkSetting-init: dry-run"* ]]
}
