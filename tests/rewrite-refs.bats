#!/usr/bin/env bats

setup() {
    bats_require_minimum_version 1.5.0
    root="$(mktemp -d)"
    mkdir -p "$root/set/skills/language" "$root/set/concepts/hardware/apple"
    mkdir -p "$root/out/.claude/rules/set/language"
    printf '# Language\n\n@language/narrow.md\n@language/active.md\n' >"$root/set/skills/language/language.md"
    printf '# Narrow\n' >"$root/set/skills/language/narrow.md"
    printf '# Active\n' >"$root/set/skills/language/active.md"
    printf '# Hardware\n\n@set/concepts/hardware/apple/m4.md\n' >"$root/set/concepts/hardware.md"
    printf '# M4\n' >"$root/set/concepts/hardware/apple/m4.md"
    printf '%s|%s\n' \
        "$root/set/skills/language/language.md" "$root/out/.claude/rules/set/language/language.md" \
        "$root/set/skills/language/narrow.md" "$root/out/.claude/rules/set/language/narrow.md" \
        "$root/set/skills/language/active.md" "$root/out/.claude/rules/set/language/active.md" \
        "$root/set/concepts/hardware.md" "$root/out/.claude/rules/set/concepts-hardware.md" \
        "$root/set/concepts/hardware/apple/m4.md" "$root/out/.claude/rules/set/concepts-hardware-apple-m4.md" >"$root/map"
    export REF_MATCH="$BATS_TEST_DIRNAME/../lib/ref-match.sh" REF_MAP="$root/map" SET_ROOT="$root"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/rewrite-refs.sh"
}

teardown() { rm -rf "$root"; }

@test "rewrites relative language refs relative to emitted sibling" {
    SRC="$root/set/skills/language/language.md" DEST="$root/out/.claude/rules/set/language/language.md" \
        bash "$SCRIPT" >"$root/out/.claude/rules/set/language/language.md"
    grep -qx '@narrow.md' <(sed -n '3p' "$root/out/.claude/rules/set/language/language.md")
    grep -qx '@active.md' <(sed -n '4p' "$root/out/.claude/rules/set/language/language.md")
}

@test "rewrites flattened concept refs" {
    SRC="$root/set/concepts/hardware.md" DEST="$root/out/.claude/rules/set/concepts-hardware.md" \
        bash "$SCRIPT" >"$root/out/.claude/rules/set/concepts-hardware.md"
    grep -qx '@concepts-hardware-apple-m4.md' <(sed -n '3p' "$root/out/.claude/rules/set/concepts-hardware.md")
}

@test "drops refs whose targets are not emitted" {
    sed -i '/active.md/d' "$root/map"
    SRC="$root/set/skills/language/language.md" DEST="$root/out/.claude/rules/set/language/language.md" \
        bash "$SCRIPT" >"$root/out/.claude/rules/set/language/language.md"
    ! grep -q '@active.md' "$root/out/.claude/rules/set/language/language.md"
}
