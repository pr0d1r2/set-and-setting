#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/ci-lint-qemu-order.sh"
}

teardown() { rm -rf "$TMP"; }

@test "QEMU before installer is clean" {
    printf '%s\n' \
        'jobs:' \
        '  arm:' \
        '    steps:' \
        '      - uses: docker/setup-qemu-action@v3' \
        '      - uses: cachix/install-nix-action@v27' \
        '      - uses: pr0d1r2/nix-lefthook-ci-action@v1' \
        '        with:' \
        '          extra-platforms: aarch64-linux' >"$TMP/ci.yml"
    run bash "$SCRIPT" "$TMP/ci.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "installer before QEMU is a finding with both positions" {
    printf '%s\n' \
        'jobs:' \
        '  arm:' \
        '    steps:' \
        '      - uses: actions/checkout@v4' \
        '      - uses: cachix/install-nix-action@v27' \
        '      - uses: docker/setup-qemu-action@v3' \
        '      - uses: pr0d1r2/nix-lefthook-ci-action@v1' \
        '        with:' \
        '          extra-platforms: aarch64-linux' >"$TMP/ci.yml"
    run bash "$SCRIPT" "$TMP/ci.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *"QEMU/binfmt step 3 must precede Nix installer step 2"* ]]
}

@test "native job with QEMU after installer is not inspected" {
    printf '%s\n' \
        'jobs:' \
        '  native:' \
        '    steps:' \
        '      - uses: cachix/install-nix-action@v27' \
        '      - uses: docker/setup-qemu-action@v3' \
        '      - run: nix flake check' >"$TMP/ci.yml"
    run bash "$SCRIPT" "$TMP/ci.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
