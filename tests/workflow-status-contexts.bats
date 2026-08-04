#!/usr/bin/env bats

setup() {
    bats_require_minimum_version 1.5.0
    DERIVER="$BATS_TEST_DIRNAME/../lib/workflow-status-contexts.nix"
    CALLER="$BATS_TEST_DIRNAME/fixtures/workflows/caller.yml"
    REUSABLE="$BATS_TEST_DIRNAME/fixtures/workflows/reusable.yml"
    RENAMED="$BATS_TEST_DIRNAME/fixtures/workflows/reusable-renamed.yml"
}

@test "derives contexts from reusable caller and workflow job names" {
    run nix eval --extra-experimental-features 'nix-command flakes' \
        --impure --json --expr \
        "import $DERIVER { callerWorkflow = $CALLER; reusableWorkflow = $REUSABLE; }"
    [ "$status" -eq 0 ]
    [ "$output" = '["guardrails / check","guardrails / check-darwin"]' ]
}

@test "ordinary caller jobs do not create reusable workflow contexts" {
    run nix eval --extra-experimental-features 'nix-command flakes' \
        --impure --json --expr \
        "import $DERIVER { callerWorkflow = $CALLER; reusableWorkflow = $RENAMED; }"
    [ "$status" -eq 0 ]
    [ "$output" = '["guardrails / verify"]' ]
}

@test "a reusable workflow job rename changes the required context" {
    run nix eval --extra-experimental-features 'nix-command flakes' \
        --impure --json --expr \
        "import $DERIVER { callerWorkflow = $CALLER; reusableWorkflow = $RENAMED; }"
    [ "$status" -eq 0 ]
    [ "$output" = '["guardrails / verify"]' ]
}

@test "the standard map matches its materialized workflows" {
    run nix eval --extra-experimental-features 'nix-command flakes' \
        --json --file "$BATS_TEST_DIRNAME/../lib/check-fragment-map.nix" \
        requiredStatusContexts
    [ "$status" -eq 0 ]
    [ "$output" = '["guardrails / check","guardrails / check-darwin"]' ]
}
