#!/usr/bin/env bats

# Contract coverage for setting/lib/mk-dev-shells.nix.

@test "ruby devShell is exposed across supported systems" {
    run nix --extra-experimental-features "nix-command flakes" \
        eval --json .#devShells --apply '
        shells:
        builtins.mapAttrs (_system: devShells: builtins.hasAttr "ruby" devShells) shells
    '

    [ "$status" -eq 0 ]
    [[ "$output" == *'"aarch64-darwin":true'* ]]
    [[ "$output" == *'"aarch64-linux":true'* ]]
    [[ "$output" == *'"x86_64-darwin":true'* ]]
    [[ "$output" == *'"x86_64-linux":true'* ]]
}

@test "ruby devShell exposes ruby and bundle" {
    run nix --extra-experimental-features "nix-command flakes" \
        develop .#ruby --command sh -c \
        'command -v ruby && command -v bundle && ruby --version && bundle --version'

    [ "$status" -eq 0 ]
    [[ "$output" == *"ruby "* ]]
    [[ "$output" == *"Bundler version"* ]]
}
