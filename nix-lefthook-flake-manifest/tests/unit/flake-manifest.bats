#!/usr/bin/env bats

setup() {
    TEST_ROOT="$(mktemp -d)"
    CHECK="$BATS_TEST_DIRNAME/../../lefthook-flake-manifest.sh"
    cd "$TEST_ROOT" || exit 1
}

teardown() {
    rm -rf "$TEST_ROOT"
}

@test "manifest delegation passes" {
    cat >flake.nix <<'EOF'
{
    description = "component";
    nixConfig = { extra-substituters = [ ]; };
    inputs = { nixpkgs.url = "github:NixOS/nixpkgs"; };
    outputs = inputs: import ./flake inputs;
}
EOF
    run bash "$CHECK"
    [ "$status" -eq 0 ]
}

@test "mkConsumerFlake delegation passes" {
    cat >flake.nix <<'EOF'
{
    inputs = { set-and-setting.url = "github:pr0d1r2/set-and-setting"; };
    outputs = { self, set-and-setting, ... }:
        set-and-setting.lib.mkConsumerFlake {
            inherit self;
        };
}
EOF
    run bash "$CHECK"
    [ "$status" -eq 0 ]
}

@test "monolith let body fails" {
    cat >flake.nix <<'EOF'
{
    inputs = { };
    outputs = inputs:
        let
            forAllSystems = inputs.nixpkgs.lib.genAttrs [ "x86_64-linux" ];
        in {
            checks = forAllSystems (_: { });
        };
}
EOF
    run bash "$CHECK"
    [ "$status" -ne 0 ]
    [[ "$output" == *"outputs body must not be a let expression"* ]]
}

@test "inline outputs attrset fails" {
    cat >flake.nix <<'EOF'
{
    inputs = { };
    outputs = inputs: { checks = { }; };
}
EOF
    run bash "$CHECK"
    [ "$status" -ne 0 ]
    [[ "$output" == *"must delegate, not construct an attrset"* ]]
}

@test "unexpected top-level attribute fails" {
    cat >flake.nix <<'EOF'
{
    inputs = { };
    systems = [ "x86_64-linux" ];
    outputs = inputs: import ./flake inputs;
}
EOF
    run bash "$CHECK"
    [ "$status" -ne 0 ]
    [[ "$output" == *"top-level attribute systems is not allowed"* ]]
}

@test "computed inputs fail" {
    cat >flake.nix <<'EOF'
{
    inputs = import ./inputs.nix;
    outputs = inputs: import ./flake inputs;
}
EOF
    run bash "$CHECK"
    [ "$status" -ne 0 ]
    [[ "$output" == *"inputs must be a literal attrset"* ]]
}

@test "missing flake skips" {
    run bash "$CHECK"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nothing to check"* ]]
}

@test "let-only strictness permits a direct inline attrset" {
    cat >flake.nix <<'EOF'
{
    outputs = inputs: { packages = { }; };
}
EOF
    run env FLAKE_MANIFEST_STRICTNESS=let-only bash "$CHECK"
    [ "$status" -eq 0 ]
}
