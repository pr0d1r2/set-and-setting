#!/usr/bin/env bats
setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/ci-lint-token.sh"
    for i in $(seq 1 11); do printf 'input%d.url = "github:owner/input%d";\n' "$i" "$i" >>"$TMP/flake.nix"; done
}
teardown() { rm -rf "$TMP"; }

@test "many-input workflow without authentication is a finding" {
    printf '%s\n' 'jobs:' '  check:' '    runs-on: ubuntu-latest' '    steps:' '      - run: nix flake check' >"$TMP/ci.yml"
    run bash "$SCRIPT" "$TMP/flake.nix" "$TMP/ci.yml"
    [ "$status" -eq 1 ]; [[ "$output" == *"pre-build-commands"* ]]
}
@test "pre-build-commands authentication passes" {
    printf '%s\n' 'jobs:' '  check:' '    runs-on: ubuntu-latest' '    steps:' '      - uses: action@SHA' '        with:' '          pre-build-commands: |' '            echo "access-tokens = github.com=${{ secrets.GITHUB_TOKEN }}" | sudo tee -a /etc/nix/nix.conf' >"$TMP/ci.yml"
    run bash "$SCRIPT" "$TMP/flake.nix" "$TMP/ci.yml"
    [ "$status" -eq 0 ]; [ -z "$output" ]
}
@test "step environment on a composite action does not pass" {
    printf '%s\n' 'jobs:' '  check:' '    runs-on: ubuntu-latest' '    steps:' '      - uses: action@SHA' '        env:' '          NIX_CONFIG: access-tokens = github.com=${{ secrets.GITHUB_TOKEN }}' >"$TMP/ci.yml"
    run bash "$SCRIPT" "$TMP/flake.nix" "$TMP/ci.yml"
    [ "$status" -eq 1 ]
}
@test "below threshold is not inspected" {
    head -n 10 "$TMP/flake.nix" >"$TMP/flake.nix.tmp"
    mv "$TMP/flake.nix.tmp" "$TMP/flake.nix"
    printf '%s\n' 'jobs:' '  check:' '    runs-on: ubuntu-latest' >"$TMP/ci.yml"
    run bash "$SCRIPT" "$TMP/flake.nix" "$TMP/ci.yml"
    [ "$status" -eq 0 ]; [ -z "$output" ]
}
