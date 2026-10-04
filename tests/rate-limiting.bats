#!/usr/bin/env bats

@test "rate limiting skill respects server feedback and bounds retries" {
    local skill="$BATS_TEST_DIRNAME/../set/skills/generic/rate-limiting.md"

    grep -q 'HTTP 429' "$skill"
    grep -q 'Retry-After' "$skill"
    grep -q 'delta-seconds' "$skill"
    grep -q 'HTTP date' "$skill"
    grep -q 'reset, remaining, and limit headers' "$skill"
    grep -q 'exponential backoff' "$skill"
    grep -q 'random jitter' "$skill"
    grep -q 'maximum' "$skill"
    grep -q 'attempts' "$skill"
    grep -q 'Reduce concurrency' "$skill"
    grep -q 'idempotency key' "$skill"
}

@test "rate limiting skill requires timing and concurrency tests" {
    local skill="$BATS_TEST_DIRNAME/../set/skills/generic/rate-limiting.md"

    grep -q 'request is made' "$skill"
    grep -q 'advised time' "$skill"
    grep -q 'jitter stays within its bounds' "$skill"
    grep -q 'connection limit' "$skill"
}
