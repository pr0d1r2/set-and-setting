#!/usr/bin/env bats
setup() { TMP="$(mktemp -d)"; SCRIPT="$BATS_TEST_DIRNAME/../../lib/ci-lint-sha.sh"; mkdir -p "$TMP/.github/workflows"; }
teardown() { rm -rf "$TMP"; }

@test "full SHAs and local workflow paths pass" {
    printf '%s\n' 'jobs:' '  check:' '    uses: ./.github/workflows/guardrails.yml' '    steps:' '      - uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262' >"$TMP/.github/workflows/clean.yml"
    run bash -c 'cd "$1" && bash "$2" .github/workflows/clean.yml' _ "$TMP" "$SCRIPT"
    [ "$status" -eq 0 ]; [ -z "$output" ]
}
@test "tags branches and short SHAs are findings" {
    printf '%s\n' 'jobs:' '  check:' '    steps:' '      - uses: actions/checkout@v4' '      - uses: actions/checkout@main' '      - uses: actions/checkout@11d5960' >"$TMP/.github/workflows/violating.yml"
    run bash -c 'cd "$1" && bash "$2" .github/workflows/violating.yml' _ "$TMP" "$SCRIPT"
    [ "$status" -eq 1 ]; [ "$(printf '%s\n' "$output" | wc -l)" -eq 3 ]
    [[ "$output" == *'git ls-remote https://github.com/actions/checkout refs/heads/main'* ]]
}
@test "near-miss SHA is a finding and local path is exempt" {
    printf '%s\n' 'jobs:' '  check:' '    uses: ./.github/workflows/guardrails.yml' '    steps:' '      - uses: actions/checkout@11d5960a326750d5838078e36cf38b85af67726z' >"$TMP/.github/workflows/near-miss.yml"
    run bash -c 'cd "$1" && bash "$2" .github/workflows/near-miss.yml' _ "$TMP" "$SCRIPT"
    [ "$status" -eq 1 ]; [[ "$output" == *':5:'* ]]
}
@test "yaml workflow files are checked" {
    printf '%s\n' 'jobs:' '  check:' '    steps:' '      - uses: actions/checkout@v4' >"$TMP/.github/workflows/violating.yaml"
    run bash -c 'cd "$1" && bash "$2" .github/workflows/violating.yaml' _ "$TMP" "$SCRIPT"
    [ "$status" -eq 1 ]; [[ "$output" == *'violating.yaml:4:'* ]]
}
