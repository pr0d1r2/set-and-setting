#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for lib/branch-protection.sh -- branch protection (T19).

setup() {
    bats_require_minimum_version 1.5.0
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/branch-protection.sh"

    git -C "$TARGET" init --initial-branch=main
    git -C "$TARGET" config user.email "test@test.com"
    git -C "$TARGET" config user.name "test"
    git -C "$TARGET" remote add origin https://github.com/owner/repo.git
    touch "$TARGET/init"
    git -C "$TARGET" add init
    git -C "$TARGET" commit -m "init"
}

teardown() {
    chmod -R u+w "$TARGET" 2>/dev/null || true
    rm -rf "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: branch-protection"* ]]
    [[ "$output" == *"--dry-run"* ]]
    [[ "$output" == *"--repo OWNER/REPO"* ]]
    [[ "$output" == *"--branch BRANCH"* ]]
    [[ "$output" == *"--status-checks"* ]]
}

@test "unknown option fails with guidance" {
    run bash "$SCRIPT" --bogus
    [ "$status" -eq 1 ]
    [[ "$output" == *"error: unknown option"* ]]
}

@test "--repo without value fails" {
    run bash "$SCRIPT" --repo
    [ "$status" -eq 1 ]
    [[ "$output" == *"--repo requires OWNER/REPO"* ]]
}

@test "--branch without value fails" {
    run bash "$SCRIPT" --branch
    [ "$status" -eq 1 ]
    [[ "$output" == *"--branch requires a name"* ]]
}

@test "--status-checks without value fails" {
    run bash "$SCRIPT" --status-checks
    [ "$status" -eq 1 ]
    [[ "$output" == *"--status-checks requires a value"* ]]
}

@test "invalid repo format fails" {
    run bash "$SCRIPT" --repo "invalid" --dry-run
    [ "$status" -eq 1 ]
    [[ "$output" == *"error: invalid repo format"* ]]
}

@test "fails outside git repo without --repo" {
    nodir="$(mktemp -d)"
    run bash -c "cd '$nodir' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not a git repository"* ]]
    rm -rf "$nodir"
}

@test "fails without origin remote and no --repo" {
    noremote="$(mktemp -d)"
    git -C "$noremote" init --initial-branch=main
    git -C "$noremote" config user.email "test@test.com"
    git -C "$noremote" config user.name "test"
    touch "$noremote/init"
    git -C "$noremote" add init
    git -C "$noremote" commit -m "init"
    run bash -c "cd '$noremote' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 1 ]
    [[ "$output" == *"no origin remote"* ]]
    rm -rf "$noremote"
}

@test "--dry-run shows payload without applying" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would configure branch protection on owner/repo/main"* ]]
    [[ "$output" == *'"required_status_checks": null'* ]]
    [[ "$output" == *'"enforce_admins": true'* ]]
    [[ "$output" == *'"required_approving_review_count": 0'* ]]
    [[ "$output" == *'"dismiss_stale_reviews": false'* ]]
    [[ "$output" == *'"require_code_owner_reviews": false'* ]]
    [[ "$output" == *'"required_linear_history": false'* ]]
    [[ "$output" == *'"required_conversation_resolution": true'* ]]
}

@test "--dry-run with --repo uses explicit repo" {
    run bash "$SCRIPT" --dry-run --repo pr0d1r2/set-and-setting
    [ "$status" -eq 0 ]
    [[ "$output" == *"pr0d1r2/set-and-setting/main"* ]]
}

@test "--dry-run with --branch uses custom branch" {
    run bash "$SCRIPT" --dry-run --repo owner/repo --branch develop
    [ "$status" -eq 0 ]
    [[ "$output" == *"owner/repo/develop"* ]]
}

@test "--dry-run with --status-checks uses custom checks" {
    run bash "$SCRIPT" --dry-run --repo owner/repo \
        --status-checks "ci-linux,ci-darwin"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ci-linux"* ]]
    [[ "$output" == *"ci-darwin"* ]]
    [[ "$output" == *'"strict": true'* ]]
}

@test "--dry-run payload disallows force pushes" {
    run bash "$SCRIPT" --dry-run --repo owner/repo
    [ "$status" -eq 0 ]
    [[ "$output" == *'"allow_force_pushes": false'* ]]
}

@test "--dry-run payload disallows deletions" {
    run bash "$SCRIPT" --dry-run --repo owner/repo
    [ "$status" -eq 0 ]
    [[ "$output" == *'"allow_deletions": false'* ]]
}

@test "detects repo from git remote" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"owner/repo/main"* ]]
}

@test "--help shows --from-standard" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--from-standard"* ]]
}

@test "--from-standard uses REQUIRED_STATUS_CONTEXTS" {
    export REQUIRED_STATUS_CONTEXTS="guardrails / check|guardrails / check-darwin"
    run bash "$SCRIPT" --dry-run --repo owner/repo --from-standard
    [ "$status" -eq 0 ]
    [[ "$output" == *"guardrails / check"* ]]
    [[ "$output" == *"guardrails / check-darwin"* ]]
    [[ "$output" == *'"strict": true'* ]]
}

@test "--from-standard without env var fails" {
    unset REQUIRED_STATUS_CONTEXTS
    run bash "$SCRIPT" --dry-run --repo owner/repo --from-standard
    [ "$status" -eq 1 ]
    [[ "$output" == *"REQUIRED_STATUS_CONTEXTS"* ]]
}

@test "--from-standard and --status-checks are mutually exclusive" {
    export REQUIRED_STATUS_CONTEXTS="guardrails / check|guardrails / check-darwin"
    run bash "$SCRIPT" --dry-run --repo owner/repo \
        --from-standard --status-checks "ci-linux"
    [ "$status" -eq 1 ]
    [[ "$output" == *"mutually exclusive"* ]]
}
