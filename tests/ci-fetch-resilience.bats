#!/usr/bin/env bats

setup() {
    ROOT="$BATS_TEST_DIRNAME/.."
}

@test "consumer flakes fetch the standard over git with retries" {
    for flake in \
        "$ROOT/templates/leaf/flake.nix" \
        "$ROOT/setting/scaffold/component-flake.txt"; do
        grep -q 'connect-timeout = 15;' "$flake"
        grep -q 'download-attempts = 5;' "$flake"
        grep -q 'set-and-setting.url = "git+https://github.com/pr0d1r2/set-and-setting.git?ref=main";' "$flake"
        ! grep -q 'set-and-setting.url = "github:' "$flake"
    done
}

@test "reusable guardrails retry every live Nix fetch" {
    workflow="$ROOT/.github/workflows/guardrails.yml"

    grep -q '^env:$' "$workflow"
    grep -q 'connect-timeout = 15' "$workflow"
    grep -q 'download-attempts = 5' "$workflow"
}

@test "every guardrail Nix operation falls back when substituters fail" {
    workflow="$ROOT/.github/workflows/guardrails.yml"

    grep -Fq 'nix develop --fallback --command true' "$workflow"
    grep -Fq 'nix run --fallback .#confirm' "$workflow"
    grep -Fq 'nix build .#setting --fallback --print-out-paths --no-link' "$workflow"
    grep -Fq 'nix flake check \' "$workflow"
    grep -Fq '            --fallback \' "$workflow"
    grep -Fq 'nix develop --fallback --command lefthook-bats-parse' "$workflow"
    grep -Fq 'nix develop --fallback --command lefthook-bats-unit' "$workflow"
    grep -Fq 'nix develop --fallback --command lefthook-tdd-order-bats' "$workflow"
}

@test "delivery builds fall back when the shared cache is unavailable" {
    workflow="$ROOT/.github/workflows/ci.yml"

    [ "$(grep -Fc 'run: nix build .#set .#setting --fallback --no-link' "$workflow")" -eq 2 ]
}

@test "CI authenticates GitHub flake resolution and refreshes cached refs" {
    workflow="$ROOT/.github/workflows/guardrails.yml"

    grep -Fq 'access-tokens = github.com=${{ secrets.GITHUB_TOKEN }}' "$workflow"
    grep -Fq 'nix flake check \' "$workflow"
    grep -Fq '            --refresh \' "$workflow"
}

@test "Darwin Nix installer is pinned to an immutable commit" {
    workflow="$ROOT/.github/workflows/guardrails.yml"

    grep -Eq '^      - uses: DeterminateSystems/nix-installer-action@[0-9a-f]{40}$' "$workflow"
    ! grep -q 'DeterminateSystems/nix-installer-action@main' "$workflow"
}
