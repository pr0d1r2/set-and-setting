#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# lib/migrate.sh flake reconciliation: the scope of the top-level let and of
# a recursive outputs set (#620 review follow-ups). Shared setup comes from
# migrate-helpers.bash, whose setup loads ../git-env (B97).
load migrate-helpers

_flake() { printf '%s\n' "{" "  inputs.nixpkgs.url = \"github:NixOS/nixpkgs\";" "$@" "}" >flake.nix; }

@test "a per-system pkgs binding other than legacyPackages refuses the migration (#620)" {
    _flake "  outputs = { nixpkgs, ... }:" "    {" \
        "      packages = nixpkgs.lib.genAttrs [ \"x86_64-linux\" ] (system:" "        let" \
        "          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };" \
        "        in" "        { default = pkgs.hello; });" "    };"
    write_vendored_lefthook
    _init_repo

    run bash "$MIGRATE_SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"unreconcilable"* ]]
    [[ "$output" == *"pkgs binding"* ]]
}
