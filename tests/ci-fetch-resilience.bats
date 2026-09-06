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

@test "CI authenticates GitHub flake resolution and refreshes cached refs" {
    workflow="$ROOT/.github/workflows/guardrails.yml"

    grep -Fq 'access-tokens = github.com=${{ secrets.GITHUB_TOKEN }}' "$workflow"
    grep -Fq 'nix flake check \\' "$workflow"
    grep -Fq '            --refresh \\' "$workflow"
}

@test "Darwin Nix installer is pinned to an immutable commit" {
    workflow="$ROOT/.github/workflows/guardrails.yml"

    grep -Eq '^      - uses: DeterminateSystems/nix-installer-action@[0-9a-f]{40}$' "$workflow"
    ! grep -q 'DeterminateSystems/nix-installer-action@main' "$workflow"
}
