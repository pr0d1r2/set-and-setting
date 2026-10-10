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

@test "all repository delivery builds fall back to local Nix builds" {
    workflow="$ROOT/.github/workflows/ci.yml"

    for job in cache-push cache-push-darwin; do
        awk -v job="$job" '
            $0 == "  " job ":" { in_job = 1; found = 0; next }
            in_job && /^  [A-Za-z0-9_-]+:$/ { exit found ? 0 : 1 }
            in_job && /^        fallback = true$/ { found = 1 }
            END { if (in_job && found) exit 0; if (in_job) exit 1; exit 2 }
        ' "$workflow"
    done
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
