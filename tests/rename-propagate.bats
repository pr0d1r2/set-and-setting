#!/usr/bin/env bats

# Unit tests for set/lib/rename-propagate.sh -- detects upstream skill
# renames affecting consumer installs (T24/C7).

setup() {
    bats_require_minimum_version 1.5.0
    TARGET="$(mktemp -d)"
    RENAMES_OUT="$(mktemp)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/rename-propagate.sh"
}

teardown() {
    rm -rf "$TARGET"
    rm -f "$RENAMES_OUT"
}

@test "empty rename map exits 0 silently" {
    run bash -c "RENAMES_MAP='' RENAMES_OUT='$RENAMES_OUT' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "no old manifest exits 0 with no warnings" {
    run bash -c "RENAMES_MAP='old.md|new.md' OLD_MANIFEST=/nonexistent \
        TARGET_DIR='$TARGET' RENAMES_OUT='$RENAMES_OUT' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
}

@test "detects rename matching old manifest applicability" {
    printf '{"categories":["nix"],"rev":"abc","agent":"claude","applicability":{"nix/flake.md":"content:buildInputs"}}\n' \
        >"$TARGET/manifest.json"
    run bash -c "RENAMES_MAP='nix/flake.md|nix/nix-flake.md' \
        OLD_MANIFEST='$TARGET/manifest.json' TARGET_DIR='$TARGET' \
        RENAMES_OUT='$RENAMES_OUT' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Upstream skill renames detected"* ]]
    [[ "$output" == *"nix/flake.md -> nix/nix-flake.md"* ]]
    [[ "$output" == *"Synced copies updated automatically"* ]]
}

@test "detects rename matching old manifest category" {
    printf '{"categories":["generic","nix"],"rev":"abc","agent":"claude"}\n' \
        >"$TARGET/manifest.json"
    run bash -c "RENAMES_MAP='nix/flake.md|nix/nix-flake.md' \
        OLD_MANIFEST='$TARGET/manifest.json' TARGET_DIR='$TARGET' \
        RENAMES_OUT='$RENAMES_OUT' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nix/flake.md -> nix/nix-flake.md"* ]]
}

@test "detects stale @-reference in CLAUDE.md" {
    printf '{"categories":["nix"],"rev":"abc","agent":"claude"}\n' \
        >"$TARGET/manifest.json"
    printf '@.claude/rules/set/nix/flake.md\n' >"$TARGET/CLAUDE.md"
    run bash -c "RENAMES_MAP='nix/flake.md|nix/nix-flake.md' \
        OLD_MANIFEST='$TARGET/manifest.json' TARGET_DIR='$TARGET' \
        RENAMES_OUT='$RENAMES_OUT' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"CLAUDE.md references renamed skill"* ]]
    [[ "$output" == *"nix/flake.md -> nix/nix-flake.md"* ]]
}

@test "detects stale @-reference in AGENTS.md" {
    printf '{"categories":["nix"],"rev":"abc","agent":"opencode"}\n' \
        >"$TARGET/manifest.json"
    printf 'some content about nix/flake.md here\n' >"$TARGET/AGENTS.md"
    run bash -c "RENAMES_MAP='nix/flake.md|nix/nix-flake.md' \
        OLD_MANIFEST='$TARGET/manifest.json' TARGET_DIR='$TARGET' \
        RENAMES_OUT='$RENAMES_OUT' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"AGENTS.md references renamed skill"* ]]
}

@test "writes renames JSON to RENAMES_OUT" {
    printf '{"categories":["nix"],"rev":"abc","agent":"claude"}\n' \
        >"$TARGET/manifest.json"
    RENAMES_MAP='nix/flake.md|nix/nix-flake.md' \
        OLD_MANIFEST="$TARGET/manifest.json" TARGET_DIR="$TARGET" \
        RENAMES_OUT="$RENAMES_OUT" bash "$SCRIPT"
    rjson="$(cat "$RENAMES_OUT")"
    [[ "$rjson" == *'"nix/flake.md":"nix/nix-flake.md"'* ]]
}

@test "handles multiple renames" {
    printf '{"categories":["nix","security"],"rev":"abc","agent":"claude"}\n' \
        >"$TARGET/manifest.json"
    rmap="$(printf 'nix/flake.md|nix/nix-flake.md\nsecurity/hardening.md|security/harden.md')"
    run bash -c "RENAMES_MAP='$rmap' \
        OLD_MANIFEST='$TARGET/manifest.json' TARGET_DIR='$TARGET' \
        RENAMES_OUT='$RENAMES_OUT' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nix/flake.md -> nix/nix-flake.md"* ]]
    [[ "$output" == *"security/hardening.md -> security/harden.md"* ]]
}

@test "no warning when rename category not installed" {
    printf '{"categories":["generic","git"],"rev":"abc","agent":"claude"}\n' \
        >"$TARGET/manifest.json"
    run bash -c "RENAMES_MAP='nix/flake.md|nix/nix-flake.md' \
        OLD_MANIFEST='$TARGET/manifest.json' TARGET_DIR='$TARGET' \
        RENAMES_OUT='$RENAMES_OUT' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Upstream skill renames detected"* ]]
}

@test "handles top-level skill rename (no slash in path)" {
    printf '{"categories":["cli"],"rev":"abc","agent":"claude"}\n' \
        >"$TARGET/manifest.json"
    run bash -c "RENAMES_MAP='cli.md|cli-tools.md' \
        OLD_MANIFEST='$TARGET/manifest.json' TARGET_DIR='$TARGET' \
        RENAMES_OUT='$RENAMES_OUT' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"cli.md -> cli-tools.md"* ]]
}
