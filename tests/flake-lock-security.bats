#!/usr/bin/env bats

@test "locked darwin packages are not affected by brotli or ruby CVEs" {
    run nix eval --impure --raw --expr '
      let
        flake = builtins.getFlake (toString ./.) ;
        pkgs = flake.inputs.nixpkgs.legacyPackages."aarch64-darwin";
      in pkgs.brotli.version + " " + pkgs.ruby.version
    '
    [ "$status" -eq 0 ]
    [ "$output" = "1.2.1 3.4.12" ]
}
