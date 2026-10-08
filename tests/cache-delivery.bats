#!/usr/bin/env bats

@test "main CI publishes evaluated standard paths to Cachix" {
    workflow="$BATS_TEST_DIRNAME/../.github/workflows/ci.yml"

    grep -q '^  cache-push:$' "$workflow"
    grep -q 'if: github.event_name == .push.' "$workflow"
    grep -q 'needs: guardrails' "$workflow"
    grep -q 'cachix/cachix-action@' "$workflow"
    grep -q 'nix build --fallback .#set .#setting' "$workflow"
    grep -q 'CACHIX_AUTH_TOKEN' "$workflow"
}

@test "generated consumer CI uses local fallback for materialization" {
    workflow="$BATS_TEST_DIRNAME/../setting/scaffold/ci.yml"

    [ "$(grep -c 'nix build --fallback .#setting --print-out-paths --no-link' "$workflow")" -eq 3 ]
    ! grep -q 'nix build \.#setting' "$workflow"
}
