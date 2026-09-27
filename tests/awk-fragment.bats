#!/usr/bin/env bats

# The awk fragment was half-wired: check-fragment-map.nix and awk.yml knew it,
# so confirm auto-detected it for any repository tracking *.awk, but
# wrappersForFragment had no `awk` key. Declaring it failed evaluation
# (`attribute 'awk' missing`) and omitting it failed confirm fidelity.

setup() {
    bats_require_minimum_version 1.5.0
    ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    FRAGMENT="$ROOT/setting/integrations/lefthook/awk.yml"
    WORK="$(mktemp -d)"
    BINS_EXPR="
    let
        flake = builtins.getFlake \"$ROOT\";
        pkgs = flake.inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
        mat = flake.lib.materializationFor { inherit pkgs; fragments = [ \"awk\" ]; };
    in
    pkgs.symlinkJoin { name = \"awk-fragment-bins\"; paths = mat.packages; }"
}

teardown() {
    rm -rf "$WORK"
}

@test "awk fragment materializes packages that provide its lefthook command" {
    run nix --extra-experimental-features 'nix-command flakes' build --impure \
        --no-link --print-out-paths --expr "$BINS_EXPR"
    [ "$status" -eq 0 ]
    bins="${lines[${#lines[@]} - 1]}/bin"
    command_name="$(grep -oE '[a-z-]*lefthook-gawk-lint' "$FRAGMENT")"
    [ -x "$bins/$command_name" ]
}

@test "awk fragment wrapper accepts valid awk and rejects a syntax error" {
    run nix --extra-experimental-features 'nix-command flakes' build --impure \
        --no-link --print-out-paths --expr "$BINS_EXPR"
    [ "$status" -eq 0 ]
    bins="${lines[${#lines[@]} - 1]}/bin"
    printf '{ print $1 }\n' >"$WORK/good.awk"
    printf 'BEGIN { print ( }\n' >"$WORK/bad.awk"
    run "$bins/lefthook-gawk-lint" "$WORK/good.awk"
    [ "$status" -eq 0 ]
    run "$bins/lefthook-gawk-lint" "$WORK/bad.awk"
    [ "$status" -ne 0 ]
}
