#!/usr/bin/env bats

setup() {
    bats_require_minimum_version 1.5.0
    MAP="$BATS_TEST_DIRNAME/../lib/check-fragment-map.nix"
}

@test "toml fragment is present and declares taplo" {
    fragment="$BATS_TEST_DIRNAME/../setting/integrations/lefthook/toml.yml"
    [ -f "$fragment" ]
    grep -q '^    taplo:' "$fragment"
}

@test "file-class coverage is exposed as queryable Nix data" {
    run nix --extra-experimental-features nix-command eval --json \
        --file "$MAP" coveragePerFileClass
    [ "$status" -eq 0 ]
    [[ "$output" == *\"nix\"*\"nixfmt\"* ]]
    [[ "$output" == *\"sh\"*\"shellcheck\"* ]]
    [[ "$output" == *\".github/workflows\"*\"yamllint\"* ]]
    [[ "$output" == *\"toml\"*\"taplo\"* ]]
}

@test "deliberately unlinted file classes are queryable" {
    run nix --extra-experimental-features nix-command eval --json \
        --file "$MAP" unlintedFileClasses
    [ "$status" -eq 0 ]
    [ "$output" = "{\"lock\":\"generated\"}" ]
}

@test "completeness check accepts the coverage map" {
    run nix --extra-experimental-features nix-command build \
        .#checks.x86_64-linux.check-fragment-map-complete --no-link
    [ "$status" -eq 0 ]
}
