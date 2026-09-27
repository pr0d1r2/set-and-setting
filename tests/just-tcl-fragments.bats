#!/usr/bin/env bats

# Just and Tcl are auto-detected from tracked files, so their wrapper packages
# must be materializable by consumers as well as listed in the coverage map.

setup() {
    bats_require_minimum_version 1.5.0
    ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    BINS_EXPR="
    let
        flake = builtins.getFlake \"$ROOT\";
        pkgs = flake.inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
        mat = flake.lib.materializationFor { inherit pkgs; fragments = [ \"just\" \"tcl\" ]; };
    in
    pkgs.symlinkJoin { name = \"just-tcl-fragment-bins\"; paths = mat.packages; }"
    WORK="$(mktemp -d)"
}

teardown() {
    rm -rf "$WORK"
}

@test "just and tcl fragments materialize all referenced wrappers" {
    run nix --extra-experimental-features 'nix-command flakes' build --impure \
        --no-link --print-out-paths --expr "$BINS_EXPR"
    [ "$status" -eq 0 ]
    bins="${lines[${#lines[@]} - 1]}/bin"
    [ -x "$bins/lefthook-justfile-alphabetical" ]
    [ -x "$bins/lefthook-justfile-no-embedded-shell" ]
    [ -x "$bins/lefthook-tcl-syntax" ]
}

@test "tcl wrapper checks Tcl syntax" {
    run nix --extra-experimental-features 'nix-command flakes' build --impure \
        --no-link --print-out-paths --expr "$BINS_EXPR"
    [ "$status" -eq 0 ]
    bins="${lines[${#lines[@]} - 1]}/bin"
    printf '%s\n' 'set value {' > "$WORK/bad.tcl"
    run "$bins/lefthook-tcl-syntax" "$WORK/bad.tcl"
    [ "$status" -ne 0 ]
}
