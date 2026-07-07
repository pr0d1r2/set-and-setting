#!/usr/bin/env bats
# Unit coverage for emit-rule.sh -- per-file rule writer (T47, V18/V19/V32).

setup() {
    bats_require_minimum_version 1.5.0
    SRCDIR="$(mktemp -d)"
    DESTDIR="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-rule.sh"
    printf '# Demo\n\nBody line.\n' >"$SRCDIR/demo.md"
    export COND_FIELD=paths
}

teardown() {
    rm -rf "$SRCDIR" "$DESTDIR"
    return 0
}

@test "core channel emits path-less rule (no frontmatter)" {
    SRC="$SRCDIR/demo.md" REL="generic/demo.md" DEST="$DESTDIR/demo.md" \
        CAT_CHANNEL=core CAT_GLOBS="**/*" OVERRIDES="" run bash "$SCRIPT"
    run head -1 "$DESTDIR/demo.md"
    [ "$output" = "# Demo" ]
}

@test "domain channel emits conditional frontmatter with globs" {
    SRC="$SRCDIR/demo.md" REL="nix/demo.md" DEST="$DESTDIR/demo.md" \
        CAT_CHANNEL=domain CAT_GLOBS="**/*.nix flake.lock" OVERRIDES="" \
        run bash "$SCRIPT"
    run cat "$DESTDIR/demo.md"
    [[ "$output" == ---* ]]
    [[ "$output" == *"paths:"* ]]
    [[ "$output" == *'"**/*.nix"'* ]]
    [[ "$output" == *"Body line."* ]]
}

@test "per-file override flips channel to domain" {
    printf 'generic/demo.md|domain|\n' >"$SRCDIR/ov"
    SRC="$SRCDIR/demo.md" REL="generic/demo.md" DEST="$DESTDIR/demo.md" \
        CAT_CHANNEL=core CAT_GLOBS="**/*" OVERRIDES="$(cat "$SRCDIR/ov")" \
        run bash "$SCRIPT"
    run head -1 "$DESTDIR/demo.md"
    [ "$output" = "---" ]
}

@test "paths-only override (empty channel) applies narrow globs" {
    # Regression: "|" delimiter, not tab -- tab collapses the empty
    # channel field and misassigns globs.
    printf 'nix/demo.md||a/b/**,**/*.exp\n' >"$SRCDIR/ov"
    SRC="$SRCDIR/demo.md" REL="nix/demo.md" DEST="$DESTDIR/demo.md" \
        CAT_CHANNEL=domain CAT_GLOBS="**/*.nix" OVERRIDES="$(cat "$SRCDIR/ov")" \
        run bash "$SCRIPT"
    run cat "$DESTDIR/demo.md"
    [[ "$output" == *'"a/b/**"'* ]]
    [[ "$output" != *'"**/*.nix"'* ]]
}

@test "subtree override applies to files under that subtree (V30)" {
    printf 'test/qemu||tests/int/**,**/*.exp\n' >"$SRCDIR/ov"
    SRC="$SRCDIR/demo.md" REL="test/qemu/cleanup.md" DEST="$DESTDIR/demo.md" \
        CAT_CHANNEL=domain CAT_GLOBS="**/*.bats" OVERRIDES="$(cat "$SRCDIR/ov")" \
        run bash "$SCRIPT"
    run cat "$DESTDIR/demo.md"
    [[ "$output" == *'"tests/int/**"'* ]]
    [[ "$output" != *'"**/*.bats"'* ]]
}

@test "exact override wins over subtree prefix (V30)" {
    printf 'test/qemu||tests/int/**,**/*.exp\ntest/qemu/cleanup.md||**/*.nix\n' >"$SRCDIR/ov"
    SRC="$SRCDIR/demo.md" REL="test/qemu/cleanup.md" DEST="$DESTDIR/demo.md" \
        CAT_CHANNEL=domain CAT_GLOBS="**/*.bats" OVERRIDES="$(cat "$SRCDIR/ov")" \
        run bash "$SCRIPT"
    run cat "$DESTDIR/demo.md"
    [[ "$output" == *'"**/*.nix"'* ]]
    [[ "$output" != *'"tests/int/**"'* ]]
}

@test "globs are not shell-expanded against cwd" {
    cd "$DESTDIR"
    mkdir -p subdir && touch subdir/afile.nix
    SRC="$SRCDIR/demo.md" REL="nix/demo.md" DEST="$DESTDIR/out.md" \
        CAT_CHANNEL=domain CAT_GLOBS="**/*" OVERRIDES="" run bash "$SCRIPT"
    run grep -c '"\*\*/\*"' "$DESTDIR/out.md"
    [ "$output" = "1" ]
}

# --- T31/V23: opencode agnosticism proof (COND_FIELD=globs) ---

@test "opencode: domain emits globs frontmatter (T31/V23)" {
    SRC="$SRCDIR/demo.md" REL="nix/demo.md" DEST="$DESTDIR/demo.md" \
        CAT_CHANNEL=domain CAT_GLOBS="**/*.nix flake.lock" OVERRIDES="" \
        COND_FIELD=globs run bash "$SCRIPT"
    run cat "$DESTDIR/demo.md"
    [[ "$output" == *"globs:"* ]]
    [[ "$output" == *'"**/*.nix"'* ]]
    [[ "$output" != *"paths:"* ]]
    [[ "$output" == *"Body line."* ]]
}

@test "opencode: core emits path-less rule same as claude (T31/V23)" {
    SRC="$SRCDIR/demo.md" REL="generic/demo.md" DEST="$DESTDIR/demo.md" \
        CAT_CHANNEL=core CAT_GLOBS="**/*" OVERRIDES="" \
        COND_FIELD=globs run bash "$SCRIPT"
    run head -1 "$DESTDIR/demo.md"
    [ "$output" = "# Demo" ]
}
