#!/usr/bin/env bats
# Unit coverage for applicability.sh -- the smart-materialization filter
# (T53, V34/V35/V36).

setup() {
    bats_require_minimum_version 1.5.0
    DIR="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/applicability.sh"
    cd "$DIR" || return 1
    export CORE="generic git"
}

teardown() {
    rm -rf "$DIR"
    return 0
}

@test "core category always kept" {
    SIGNALS="generic/skill.md|**/*|"
    run env SIGNALS="$SIGNALS" CORE="$CORE" TRACKED="README.md" bash "$SCRIPT"
    [ "$output" = "generic/skill.md|core" ]
}

@test "domain kept on path evidence, pruned without" {
    SIGNALS="nix/flake.md|**/*.nix|"
    run env SIGNALS="$SIGNALS" CORE="$CORE" TRACKED="$(printf 'a/b.nix')" bash "$SCRIPT"
    [[ "$output" == "nix/flake.md|paths:"* ]]
    run env SIGNALS="$SIGNALS" CORE="$CORE" TRACKED="README.md" bash "$SCRIPT"
    [ -z "$output" ]
}

@test "leading **/ matches a top-level file" {
    SIGNALS="nix/flake.md|**/*.nix|"
    run env SIGNALS="$SIGNALS" CORE="$CORE" TRACKED="pkg.nix" bash "$SCRIPT"
    [[ "$output" == "nix/flake.md|paths:"* ]]
}

@test "content gate: kept only when a matched file contains the pattern" {
    printf 'has qemu enable-kvm here\n' >boot.exp
    printf 'nothing\n' >other.exp
    SIGNALS="test/qemu.md|**/*.exp|qemu,enable-kvm"
    run env SIGNALS="$SIGNALS" CORE="$CORE" TRACKED="$(printf 'boot.exp\nother.exp')" bash "$SCRIPT"
    [ "$output" = "test/qemu.md|content:qemu,enable-kvm" ]

    printf 'no marker\n' >boot.exp
    run env SIGNALS="$SIGNALS" CORE="$CORE" TRACKED="boot.exp" bash "$SCRIPT"
    [ -z "$output" ]
}

@test "facet -> topic core backfill when core exists" {
    printf 'qemu enable-kvm\n' >boot.exp
    SIGNALS="$(printf 'test.md|**/*.bats|\ntest/qemu.md|**/*.exp|qemu')"
    run env SIGNALS="$SIGNALS" CORE="$CORE" TRACKED="boot.exp" bash "$SCRIPT"
    [[ "$output" == *"test/qemu.md|content:qemu"* ]]
    [[ "$output" == *"test.md|required-by:test"* ]]
}

@test "no backfill when topic core absent from signals" {
    printf 'qemu enable-kvm\n' >boot.exp
    SIGNALS="test/qemu.md|**/*.exp|qemu"
    run env SIGNALS="$SIGNALS" CORE="$CORE" TRACKED="boot.exp" bash "$SCRIPT"
    [ "$output" = "test/qemu.md|content:qemu" ]
}
