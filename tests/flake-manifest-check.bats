#!/usr/bin/env bats
# Unit coverage for lib/flake-manifest-check.sh (#200) -- assert flake.nix
# is a thin manifest (no let-body, no inline attrset in outputs body).

setup() {
    bats_require_minimum_version 1.5.0
    ROOT="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/flake-manifest-check.sh"
}

teardown() {
    rm -rf "$ROOT"
    return 0
}

# --- manifest (delegation) passes -------------------------------------------

@test "import delegation passes" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    outputs = inputs: import ./flake inputs;
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "mkConsumerFlake delegation passes" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    outputs = { self, nixpkgs, set-and-setting, ... }:
        set-and-setting.lib.mkConsumerFlake {
            inherit self nixpkgs set-and-setting;
        };
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "grouped import with merge passes" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    outputs = { self, nixpkgs, set-and-setting, ... }:
        (import ./set/lib/mk-consumer-flake.nix {
            supportedSystems = [ "x86_64-linux" ];
        })
            { inherit self nixpkgs set-and-setting; src = ./.; }
        // { inherit (set-and-setting) lib; };
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "manifest with description and nixConfig passes" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    description = "My project";

    nixConfig = {
        extra-substituters = [ "https://example.cachix.org" ];
    };

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    outputs = inputs: import ./flake inputs;
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "simple identifier args with import passes" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    outputs = inputs: import ./flake inputs;
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "let-block that delegates passes" {
    # A let that binds helpers then delegates (in <import>/<call>) is a thin
    # manifest, not a monolith -- this is the repo's own bootstrap shape (B41).
    cat > "$ROOT/flake.nix" <<'EOF'
{
    outputs = { self, nixpkgs, set-and-setting, ... }:
        let
            sasLib = set-and-setting.lib or set-and-setting.inputs.set-and-setting.lib;
        in
        (import ./set/lib/mk-consumer-flake.nix { })
            { inherit self nixpkgs set-and-setting; lib = sasLib; }
        // { inherit (set-and-setting) lib; };
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

# --- monolith (let ... in attrset) fails -------------------------------------

@test "let-body with destructured args fails" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    outputs = { self, nixpkgs, ... }:
        let
            forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
        in
        {
            checks = forAllSystems (system: { });
            packages = forAllSystems (system: { });
        };
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"let-block"* ]]
}

@test "let-body with simple identifier args fails" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    outputs = inputs:
        let
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        in
        {
            packages.x86_64-linux.default = pkgs.hello;
        };
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"let-block"* ]]
}

# --- monolith (inline attrset) fails ----------------------------------------

@test "inline attrset with destructured args fails" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    outputs = { self, nixpkgs, ... }: {
        checks = { };
        packages = { };
    };
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"inline attrset"* ]]
}

@test "inline attrset with simple identifier args fails" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    outputs = inputs: {
        packages = { };
    };
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"inline attrset"* ]]
}

# --- skip / edge cases -------------------------------------------------------

@test "non-flake.nix file is skipped" {
    printf 'outputs = inputs: let x = 1; in { };\n' > "$ROOT/other.nix"
    run bash "$SCRIPT" "$ROOT/other.nix"
    [ "$status" -eq 0 ]
    [[ "$output" == "" ]]
}

@test "missing flake.nix is skipped" {
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 0 ]
}

@test "no arguments exits 0" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "comments are stripped before matching" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    # This has comments everywhere
    outputs = inputs:
        # Even here
        import ./flake inputs;
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "multi-line destructured args handled correctly" {
    cat > "$ROOT/flake.nix" <<'EOF'
{
    outputs =
        {
            self,
            nixpkgs,
            set-and-setting,
            ...
        }:
        import ./flake {
            inherit self nixpkgs set-and-setting;
        };
}
EOF
    run bash "$SCRIPT" "$ROOT/flake.nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

# --- multiple files ----------------------------------------------------------

@test "one pass and one fail yields exit 1" {
    mkdir -p "$ROOT/a" "$ROOT/b"
    cat > "$ROOT/a/flake.nix" <<'EOF'
{ outputs = inputs: import ./flake inputs; }
EOF
    cat > "$ROOT/b/flake.nix" <<'EOF'
{ outputs = inputs: let x = 1; in { }; }
EOF
    run bash "$SCRIPT" "$ROOT/a/flake.nix" "$ROOT/b/flake.nix"
    [ "$status" -eq 1 ]
    [[ "$output" == *"PASS"* ]]
    [[ "$output" == *"FAIL"* ]]
}
