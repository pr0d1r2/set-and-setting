#!/usr/bin/env bats
setup() { TMP="$(mktemp -d)"; SCRIPT="$BATS_TEST_DIRNAME/../../lib/lint-badge-version.sh"; }
teardown() { rm -rf "$TMP"; }
write_fixture() { printf '%s\n' "$1" >"$TMP/flake.nix"; printf '%s\n' "$2" >"$TMP/README.md"; }
@test "matching channel and badge pass" {
  write_fixture 'nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";' '[![NixOS 25.11](https://img.shields.io/badge/NixOS-25.11-blue.svg?logo=nixos)](https://nixos.org)'
  run bash "$SCRIPT" "$TMP/flake.nix" "$TMP/README.md"; [ "$status" -eq 0 ]; [ -z "$output" ]
}
@test "different badge version is a finding" {
  write_fixture 'nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";' '[![NixOS 24.11](https://img.shields.io/badge/NixOS-24.11-blue.svg?logo=nixos)](https://nixos.org)'
  run bash "$SCRIPT" "$TMP/flake.nix" "$TMP/README.md"; [ "$status" -ne 0 ]; [[ "$output" == *"24.11"* && "$output" == *"25.11"* && "$output" == *"expected badge line"* ]]
}
@test "revision-pinned nixpkgs is unknown" {
  write_fixture 'nixpkgs.url = "github:NixOS/nixpkgs/0123456789abcdef0123456789abcdef01234567";' '[![NixOS 25.11](https://img.shields.io/badge/NixOS-25.11-blue.svg?logo=nixos)](https://nixos.org)'
  run bash "$SCRIPT" "$TMP/flake.nix" "$TMP/README.md"; [ "$status" -ne 0 ]; [[ "$output" == *"unknown"* ]]
}
@test "near-miss URL does not count as a channel" {
  write_fixture 'other.url = "github:NixOS/nixpkgs/nixos-25.11";' '[![NixOS 25.11](https://img.shields.io/badge/NixOS-25.11-blue.svg?logo=nixos)](https://nixos.org)'
  run bash "$SCRIPT" "$TMP/flake.nix" "$TMP/README.md"; [ "$status" -ne 0 ]; [[ "$output" == *"unknown"* ]]
}

@test "lock ref supplies a follows-based channel" {
  write_fixture 'nixpkgs.follows = "nixpkgs-lock/nixpkgs";' '[![NixOS 26.05](https://img.shields.io/badge/NixOS-26.05-blue.svg?logo=nixos)](https://nixos.org)'
  printf '%s\n' '"ref": "nixos-26.05"' >"$TMP/flake.lock"
  run bash "$SCRIPT" "$TMP/flake.nix" "$TMP/README.md" "$TMP/flake.lock"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
