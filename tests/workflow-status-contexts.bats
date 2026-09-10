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

# ---- #421: a matrix RENAMES every context it touches ------------------------
# GitHub reports a matrix job as `job (v)` -- or `job (v1, v2)` for several keys,
# in declaration order -- and nothing reports the bare `job` any more. Branch
# protection requires contexts BY NAME, and a required context nobody reports
# never fails: it stays pending forever and the PR can never merge. So the
# deriver learns matrices while the workflows here still have none, which is the
# only moment the change is provably a no-op.

eval_contexts() {
    nix eval --extra-experimental-features 'nix-command flakes' \
        --impure --json --expr \
        "import $DERIVER { callerWorkflow = $1; reusableWorkflow = $2; }"
}

@test "#421: a matrix in the reusable workflow expands to one context per value" {
    run eval_contexts "$CALLER" "$BATS_TEST_DIRNAME/fixtures/workflows/reusable-matrix.yml"
    [ "$status" -eq 0 ]
    [ "$output" = '["guardrails / check (x86_64-linux)","guardrails / check (aarch64-linux)","guardrails / check-darwin"]' ]
}

@test "#421: a block-style matrix list reads the same as a flow-style one" {
    # `fail-fast:` sits beside `matrix:` under `strategy:`; a boundary test that
    # closed the block on it would silently see no matrix at all -- and "no
    # matrix" is exactly the wrong answer that renames every context.
    run eval_contexts "$CALLER" "$BATS_TEST_DIRNAME/fixtures/workflows/reusable-matrix-block.yml"
    [ "$status" -eq 0 ]
    [ "$output" = '["guardrails / check (x86_64-linux)","guardrails / check (aarch64-linux)","guardrails / check (aarch64-darwin)"]' ]
}

@test "#421: two matrix keys give the cartesian product in declaration order" {
    run eval_contexts "$CALLER" "$BATS_TEST_DIRNAME/fixtures/workflows/reusable-matrix-two-keys.yml"
    [ "$status" -eq 0 ]
    [ "$output" = '["guardrails / check (x86_64-linux, stable)","guardrails / check (x86_64-linux, unstable)","guardrails / check (aarch64-darwin, stable)","guardrails / check (aarch64-darwin, unstable)"]' ]
}

@test "#421: matrix include/exclude THROWS rather than derive a plausible name" {
    # `include` adds combinations this parser cannot see. A wrong name here is
    # worse than no answer: it is required, never reported, and pending forever.
    run eval_contexts "$CALLER" "$BATS_TEST_DIRNAME/fixtures/workflows/reusable-matrix-include.yml"
    [ "$status" -ne 0 ]
    [[ "$output" == *"include/exclude is not supported"* ]]
}

@test "#421: a matrix on the CALLER side expands on the left of the slash" {
    run eval_contexts "$BATS_TEST_DIRNAME/fixtures/workflows/caller-matrix.yml" "$REUSABLE"
    [ "$status" -eq 0 ]
    [ "$output" = '["guardrails (minimal) / check","guardrails (minimal) / check-darwin","guardrails (full) / check","guardrails (full) / check-darwin"]' ]
}

@test "#421: the standard's own derived set is UNCHANGED by matrix support" {
    # The whole point of landing the parser first: with today's non-matrix
    # workflows the required contexts are byte-identical, so branch protection
    # keeps requiring exactly what CI keeps reporting.
    run nix eval --extra-experimental-features 'nix-command flakes' \
        --json --file "$BATS_TEST_DIRNAME/../lib/check-fragment-map.nix" \
        requiredStatusContexts
    [ "$status" -eq 0 ]
    [ "$output" = '["guardrails / check","guardrails / check-darwin"]' ]
}
