#!/usr/bin/env bats

assert_job_timeout() {
    local workflow="$1"
    local job="$2"

    awk -v job="$job" '
        $0 == "  " job ":" { in_job = 1; found = 0; next }
        in_job && /^  [A-Za-z0-9_-]+:$/ {
            exit found ? 0 : 1
        }
        in_job && /^    timeout-minutes: 15$/ { found = 1 }
        END {
            if (in_job && found) exit 0
            if (in_job) exit 1
            exit 2
        }
    ' "$workflow"
}

@test "every repository CI job has a 15 minute timeout" {
    workflow="$BATS_TEST_DIRNAME/../.github/workflows/ci.yml"

    for job in lock-budget-comment cache-push cache-push-darwin; do
        assert_job_timeout "$workflow" "$job"
    done
}

@test "both reusable guardrails jobs have a 15 minute timeout" {
    workflow="$BATS_TEST_DIRNAME/../.github/workflows/guardrails.yml"

    for job in check check-darwin; do
        assert_job_timeout "$workflow" "$job"
    done
}

@test "the reusable workflow provides the timeout for generated leaf CI callers" {
    workflow="$BATS_TEST_DIRNAME/../setting/scaffold/leaf-ci.yml"

    grep -q 'uses: pr0d1r2/set-and-setting/.github/workflows/guardrails.yml@main' "$workflow"
    assert_job_timeout "$BATS_TEST_DIRNAME/../.github/workflows/guardrails.yml" check
    assert_job_timeout "$BATS_TEST_DIRNAME/../.github/workflows/guardrails.yml" check-darwin
}
