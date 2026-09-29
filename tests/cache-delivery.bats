#!/usr/bin/env bats

@test "main CI publishes evaluated standard paths to Cachix" {
    workflow="$BATS_TEST_DIRNAME/../.github/workflows/ci.yml"

    grep -q '^  cache-push:$' "$workflow"
    grep -q '^  cache-push-darwin:$' "$workflow"
    grep -q 'if: github.event_name == .push.' "$workflow"
    grep -q 'needs: guardrails' "$workflow"
    grep -q 'cachix/cachix-action@5f2d7c5294214f71b873db4b969586b980625e71 # v17' "$workflow"
    grep -q 'nix build .#set .#setting' "$workflow"
    grep -q 'CACHIX_AUTH_TOKEN' "$workflow"
}
