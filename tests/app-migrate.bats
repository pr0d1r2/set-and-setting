#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for lib/app-migrate.sh -- CLI wrapper for the migrator (#96).

setup() {
    bats_require_minimum_version 1.5.0
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/app-migrate.sh"

    mkdir -p "$TARGET/mock-bin"
    cat >"$TARGET/mock-bin/migrate-mock.sh" <<'MOCK'
#!/usr/bin/env bash
if [ "${MIGRATE_DETECT_ONLY:-}" = "1" ]; then
    echo "migrate: detected state=vendored"
    exit 0
fi
if [ "${MIGRATE_DRY_RUN:-}" = "1" ]; then
    echo "migrate: dry-run plan for state=vendored"
    exit 0
fi
echo "migrate: vendored -> referenced complete."
MOCK
    chmod +x "$TARGET/mock-bin/migrate-mock.sh"

    export MIGRATE_SCRIPT="$TARGET/mock-bin/migrate-mock.sh"
    cd "$TARGET" || exit 1
}

teardown() {
    cd /
    rm -rf "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: migrate"* ]]
    [[ "$output" == *"vendored->referenced"* ]]
    [[ "$output" == *"equivalence"* ]]
}

@test "--detect sets MIGRATE_DETECT_ONLY and prints state" {
    run bash "$SCRIPT" --detect
    [ "$status" -eq 0 ]
    [[ "$output" == *"detected state=vendored"* ]]
    [[ "$output" != *"complete"* ]]
}

@test "--dry-run sets MIGRATE_DRY_RUN and prints the plan" {
    run bash "$SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run plan"* ]]
}

@test "default mode runs the migrate script" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"vendored -> referenced complete"* ]]
}
