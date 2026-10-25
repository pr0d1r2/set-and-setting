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

@test "a per-system let is not taken for the top-level let when outputs has none (#620)" {
    _flake "  outputs = { nixpkgs, ... }:" "    {" \
        "      packages = nixpkgs.lib.genAttrs [ \"x86_64-linux\" ] (system:" "        let" \
        "          pkgs = nixpkgs.legacyPackages.\${system};" "          tool = pkgs.hello;" \
        "        in" "        {" "          default = tool;" "        });" "    };"
    write_vendored_lefthook
    _init_repo

    run bash "$MIGRATE_SCRIPT"

    [ "$status" -eq 0 ]
    nix-instantiate --parse flake.nix >/dev/null
    [ "$(grep -c 'tool = pkgs.hello;' flake.nix)" -eq 1 ]
}

@test "a top-level let on the outputs header line is carried (#620)" {
    _flake "  outputs = { nixpkgs, ... }: let" \
        "      consumerPackage = nixpkgs.legacyPackages.x86_64-linux.hello;" "    in" "    {" \
        "      packages.x86_64-linux.default = consumerPackage;" "    };"
    write_vendored_lefthook
    _init_repo

    run bash "$MIGRATE_SCRIPT"

    [ "$status" -eq 0 ]
    nix-instantiate --parse flake.nix >/dev/null
    grep -q 'consumerPackage = nixpkgs.legacyPackages.x86_64-linux.hello;' flake.nix
}

@test "a nested rec set does not send local names through self (#620)" {
    _flake "  outputs = { nixpkgs, ... }:" "    {" \
        "      packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.stdenv.mkDerivation rec {" \
        "        pname = \"x\";" "        version = \"1\";" "        src = ./.;" "      };" \
        "      overlays.default = final: prev: let packages = { foo = prev.hello; }; in { foo = packages.foo; };" "    };"
    write_vendored_lefthook
    _init_repo

    run bash "$MIGRATE_SCRIPT"

    [ "$status" -eq 0 ]
    grep -q 'foo = packages.foo;' flake.nix
    run ! grep -q 'self.packages' flake.nix
}
