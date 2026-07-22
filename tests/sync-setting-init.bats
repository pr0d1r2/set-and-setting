#!/usr/bin/env bats

# Unit tests for setting/lib/sync-setting-init.sh -- scaffolds seed
# files into a target directory, skipping files that already exist.

setup() {
    SRC="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/sync-setting-init.sh"
    WRAPPER="$(mktemp)"
    printf 'src="%s"\n' "$SRC" >"$WRAPPER"
    cat "$SCRIPT" >>"$WRAPPER"
    echo "editorconfig" >"$SRC/.editorconfig"
    echo "gitattributes" >"$SRC/.gitattributes"
    echo "gitignore" >"$SRC/.gitignore"
    mkdir -p "$SRC/config/lefthook"
    echo "limits" >"$SRC/config/lefthook/file_size_limits.yml"
    printf '%s\n' '# __REPO__' 'https://github.com/__OWNER__/__REPO__' >"$SRC/README.md"
    echo 'Copyright (c) __YEAR__ __HOLDER__' >"$SRC/LICENSE"
}

teardown() {
    rm -rf "$SRC" "$TARGET" "$WRAPPER"
}

@test "scaffolds seed files into explicit target" {
    run bash "$WRAPPER" "$TARGET"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced setting-init"* ]]
    [ -f "$TARGET/.editorconfig" ]
    [ "$(cat "$TARGET/.editorconfig")" = "editorconfig" ]
    [ -f "$TARGET/.gitattributes" ]
    [ -f "$TARGET/.gitignore" ]
    [ -f "$TARGET/config/lefthook/file_size_limits.yml" ]
    [ "$(head -1 "$TARGET/README.md")" = "# ${TARGET##*/}" ]
    grep -q '__OWNER__/__REPO__' "$TARGET/README.md"
    grep -q '__YEAR__ __HOLDER__' "$TARGET/LICENSE"
}

@test "skips existing README and LICENSE" {
    echo "custom readme" >"$TARGET/README.md"
    echo "custom license" >"$TARGET/LICENSE"
    run bash "$WRAPPER" "$TARGET"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/README.md")" = "custom readme" ]
    [ "$(cat "$TARGET/LICENSE")" = "custom license" ]
}

@test "defaults to cwd when no target argument" {
    run bash -c "cd '$TARGET' && bash '$WRAPPER'"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.editorconfig" ]
}

@test "skips files that already exist" {
    echo "custom" >"$TARGET/.editorconfig"
    run bash "$WRAPPER" "$TARGET"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/.editorconfig")" = "custom" ]
    [ -f "$TARGET/.gitattributes" ]
}

@test "creates parent directories for nested files" {
    run bash "$WRAPPER" "$TARGET"
    [ "$status" -eq 0 ]
    [ -d "$TARGET/config/lefthook" ]
    [ -f "$TARGET/config/lefthook/file_size_limits.yml" ]
}

@test "scaffolds narrow-language dics" {
    touch "$SRC/.narrow-language-nix.dic"
    touch "$SRC/.narrow-language-shell.dic"
    printf 'src="%s"\n' "$SRC" >"$WRAPPER"
    cat "$SCRIPT" >>"$WRAPPER"
    run bash "$WRAPPER" "$TARGET"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.narrow-language-nix.dic" ]
    [ -f "$TARGET/.narrow-language-shell.dic" ]
}

@test "skips existing narrow-language dics" {
    touch "$SRC/.narrow-language-nix.dic"
    printf 'src="%s"\n' "$SRC" >"$WRAPPER"
    cat "$SCRIPT" >>"$WRAPPER"
    echo "custom words" >"$TARGET/.narrow-language-nix.dic"
    run bash "$WRAPPER" "$TARGET"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/.narrow-language-nix.dic")" = "custom words" ]
}
