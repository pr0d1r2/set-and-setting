#!/usr/bin/env bats

@test "main CI publishes evaluated standard paths to Cachix" {
    workflow="$BATS_TEST_DIRNAME/../.github/workflows/ci.yml"

    grep -q '^  cache-push:$' "$workflow"
    grep -q 'if: github.event_name == .push.' "$workflow"
    grep -q 'needs: guardrails' "$workflow"
    grep -q 'cachix/cachix-action@' "$workflow"
    grep -q 'bash .github/scripts/cache-build.sh' "$workflow"
    grep -q 'nix build .#set .#setting' "$BATS_TEST_DIRNAME/../.github/scripts/cache-build.sh"
    grep -q 'CACHIX_AUTH_TOKEN' "$workflow"
}
