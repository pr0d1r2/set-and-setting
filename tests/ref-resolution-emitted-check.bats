#!/usr/bin/env bats

setup() {
    fixture="$(mktemp -d)"
    trap 'rm -rf "$fixture"' EXIT
    matcher="$BATS_TEST_DIRNAME/../lib/ref-match.sh"
    checker="$BATS_TEST_DIRNAME/../lib/ref-resolution-emitted-check.sh"
}

@test "resolves refs relative to the emitted file" {
    mkdir -p "$fixture/set"
    printf '@set/target.md\n' >"$fixture/source.md"
    printf '# target\n' >"$fixture/set/target.md"

    run env ARTIFACT_ROOT="$fixture" REF_MATCH="$matcher" bash "$checker"

    [ "$status" -eq 0 ]
    [[ "$output" == *"all @-references resolve"* ]]
}

@test "fails with emitted file, line, and unresolved target" {
    mkdir -p "$fixture/set"
    printf '# source\n@set/missing.md\n' >"$fixture/source.md"

    run env ARTIFACT_ROOT="$fixture" REF_MATCH="$matcher" bash "$checker"

    [ "$status" -eq 1 ]
    [[ "$output" == *"source.md:2"* ]]
    [[ "$output" == *"@set/missing.md"* ]]
}
