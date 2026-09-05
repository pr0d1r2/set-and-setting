#!/usr/bin/env bats

# .github/workflows/guardrails.yml -- the reusable workflow every tended
# consumer calls as `@main`, so its invariants are fleet invariants (#489).

setup() {
    WF="$BATS_TEST_DIRNAME/../../../.github/workflows/guardrails.yml"
}

@test "a superseded run is cancelled, so a force-push does not queue behind itself" {
    run grep -A3 '^concurrency:' "$WF"
    [ "$status" -eq 0 ]
    [[ "$output" == *"cancel-in-progress"* ]]
}

@test "the concurrency group is per ref, not per repository" {
    # A repository-wide group would serialise unrelated pull requests.
    run grep -A2 '^concurrency:' "$WF"
    [[ "$output" == *'github.ref'* ]]
}

@test "cancellation is limited to pull requests -- never the default branch" {
    # Cancelling on the default branch would kill the cache-push that follows a
    # merge, which is the whole reason the cache exists.
    run grep -A3 '^concurrency:' "$WF"
    [[ "$output" == *"github.event_name == 'pull_request'"* ]]
    [[ "$output" != *"cancel-in-progress: true"* ]]
}

@test "both platform jobs still run, and darwin is not gated behind linux" {
    run grep -cE '^  check(-darwin)?:$' "$WF"
    [ "$output" -eq 2 ]
    # The comment above check-darwin explains why there is no `needs:`; assert
    # on real keys, not on prose that mentions them.
    run grep -cE '^ +needs:' "$WF"
    [ "$output" -eq 0 ]
}
