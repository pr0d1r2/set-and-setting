#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/lint-namespace-limit.sh"
}

teardown() {
    rm -rf "$TMP"
}

@test "ten entries are clean" {
    {
        echo 'in {'
        for i in $(seq 1 10); do echo "  app$i = { type = \"app\"; };"; done
        echo '}'
    } >"$TMP/apps.nix"
    run bash "$SCRIPT" "$TMP/apps.nix"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "eleven entries report split and sub remedies" {
    {
        echo 'in {'
        for i in $(seq 1 11); do echo "  app$i = { type = \"app\"; };"; done
        echo '}'
    } >"$TMP/apps.nix"
    run bash "$SCRIPT" "$TMP/apps.nix"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/apps.nix:12: namespace <root> has 11 entries; resolve the limit with a split or sub"* ]]
}

@test "sub-namespaces are counted independently" {
    {
        echo 'in {'
        for i in $(seq 1 10); do echo "  group.app$i = { type = \"app\"; };"; done
        echo '}'
    } >"$TMP/apps.nix"
    run bash "$SCRIPT" "$TMP/apps.nix"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
