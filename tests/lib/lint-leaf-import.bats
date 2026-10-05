#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    mkdir -p "$TMP/flake/apps" "$TMP/flake/checks" "$TMP/lib"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/lint-leaf-import.sh"
}

teardown() {
    rm -rf "$TMP"
}

@test "clean leaf passes" {
    printf '%s\n' '{ pkgs }: { }' >"$TMP/flake/apps/default.nix"
    run bash "$SCRIPT" "$TMP/flake/apps/default.nix"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "a check importing an app leaf is a finding" {
    printf '%s\n' 'let a = import ../apps/x.nix; in a' >"$TMP/flake/checks/y.nix"
    run bash "$SCRIPT" "$TMP/flake/checks/y.nix"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/flake/checks/y.nix:1: leaf imports sibling ../apps/x.nix"* ]]
    [[ "$output" == *"flake/lib.nix"* ]]
    [[ "$output" == *"assembler"* ]]
}

@test "import of flake/lib.nix is not a finding" {
    printf '%s\n' 'import ../lib.nix { }' >"$TMP/flake/checks/y.nix"
    run bash "$SCRIPT" "$TMP/flake/checks/y.nix"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "import of own local file is not a finding" {
    printf '%s\n' 'import ./helper.nix { }' 'import ./sub/more.nix' >"$TMP/flake/apps/default.nix"
    run bash "$SCRIPT" "$TMP/flake/apps/default.nix"
    [ "$status" -eq 0 ]
}

@test "each import resolves independently" {
    printf '%s\n' 'import ./helper.nix { }' 'import ../apps/x.nix' >"$TMP/flake/checks/y.nix"
    run bash "$SCRIPT" "$TMP/flake/checks/y.nix"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/flake/checks/y.nix:2: leaf imports sibling ../apps/x.nix"* ]]
}

@test "import reaching outside flake is not a finding" {
    printf '%s\n' 'import ../../lib/x.nix' >"$TMP/flake/apps/default.nix"
    run bash "$SCRIPT" "$TMP/flake/apps/default.nix"
    [ "$status" -eq 0 ]
}

@test "the assembler may import leaves" {
    printf '%s\n' 'import ./apps' 'import ./systems.nix' >"$TMP/flake/default.nix"
    run bash "$SCRIPT" "$TMP/flake/default.nix"
    [ "$status" -eq 0 ]
}

@test "comments naming a sibling import are not a finding" {
    printf '%s\n' '# must not import ../apps/x.nix' >"$TMP/flake/checks/y.nix"
    run bash "$SCRIPT" "$TMP/flake/checks/y.nix"
    [ "$status" -eq 0 ]
}

@test "relative path form is checked" {
    cd "$TMP"
    printf '%s\n' 'x' 'import ../apps/x.nix' >flake/checks/y.nix
    run bash "$SCRIPT" flake/checks/y.nix
    [ "$status" -eq 1 ]
    [[ "$output" == "flake/checks/y.nix:2:"* ]]
}

@test "files outside flake are ignored" {
    printf '%s\n' 'import ../apps/x.nix' >"$TMP/lib/y.nix"
    run bash "$SCRIPT" "$TMP/lib/y.nix"
    [ "$status" -eq 0 ]
}
