#!/usr/bin/env bats

# Unit tests for lefthook-narrow-language-add.sh -- appends unknown
# repo words to the dictionary (inverse of compact).

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../lefthook-narrow-language-add.sh"

    WORK="$BATS_TEST_TMPDIR/repo"
    mkdir -p "$WORK"
    git -C "$WORK" init -q
    git -C "$WORK" config user.email "test@test"
    git -C "$WORK" config user.name "Test"
}

teardown() {
    rm -rf "$WORK"
}

@test "exits 0 when dictionary is missing" {
    run bash -c "cd '$WORK' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
}

@test "exits 0 when no unknown words" {
    echo "hello world" > "$WORK/file.sh"
    printf '%s\n' "hello" "world" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    run bash -c "cd '$WORK' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" != *"adding"* ]]
}

@test "adds unknown words to dictionary" {
    echo "hello world alpha" > "$WORK/file.sh"
    printf '%s\n' "hello" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    run bash -c "cd '$WORK' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"adding 2 new"* ]]
    [[ "$output" == *"alpha"* ]]
    [[ "$output" == *"world"* ]]

    run cat "$WORK/.narrow-language.dic"
    [[ "$output" == *"alpha"* ]]
    [[ "$output" == *"hello"* ]]
    [[ "$output" == *"world"* ]]
}

@test "does not count dictionary file as word source" {
    echo "hello" > "$WORK/file.sh"
    printf '%s\n' "hello" "orphan" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    run bash -c "cd '$WORK' && NARROW_LANGUAGE_DICT=.narrow-language.dic bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" != *"adding"* ]]
}

@test "excludes flake.lock from word sources" {
    printf '%s\n' "unique" > "$WORK/flake.lock"
    echo "hello" > "$WORK/file.sh"
    printf '%s\n' "hello" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    run bash -c "cd '$WORK' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" != *"unique"* ]]
}

@test "NARROW_LANGUAGE_GLOB_INCLUDE scopes to matching files" {
    echo "hello" > "$WORK/file.nix"
    echo "world" > "$WORK/file.sh"
    printf '%s\n' "hello" > "$WORK/.narrow-language-nix.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    run bash -c "cd '$WORK' && NARROW_LANGUAGE_DICT=.narrow-language-nix.dic NARROW_LANGUAGE_GLOB_INCLUDE='\.nix$' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" != *"world"* ]]
}

@test "without NARROW_LANGUAGE_GLOB_INCLUDE scans all files" {
    echo "hello" > "$WORK/file.nix"
    echo "world" > "$WORK/file.sh"
    printf '%s\n' "place" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    run bash -c "cd '$WORK' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"adding"* ]]
    [[ "$output" == *"hello"* ]]
    [[ "$output" == *"world"* ]]
}

@test "auto-excludes own dictionary from word sources" {
    echo "hello" > "$WORK/file.sh"
    printf '%s\n' "hello" > "$WORK/.narrow-language-shell.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    run bash -c "cd '$WORK' && NARROW_LANGUAGE_DICT=.narrow-language-shell.dic NARROW_LANGUAGE_GLOB_INCLUDE='\.(sh|bats)$' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" != *"adding"* ]]
}

@test "NARROW_LANGUAGE_GLOB_INCLUDE_EXTRA appends to GLOB_INCLUDE" {
    echo "hello" > "$WORK/file.yml"
    echo "extra" > "$WORK/file.jsonc"
    printf '%s\n' "place" > "$WORK/.narrow-language-other.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    run bash -c "cd '$WORK' && NARROW_LANGUAGE_DICT=.narrow-language-other.dic NARROW_LANGUAGE_GLOB_INCLUDE='\.yml\$' NARROW_LANGUAGE_GLOB_INCLUDE_EXTRA='\.jsonc\$' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"adding"* ]]
    [[ "$output" == *"extra"* ]]
    [[ "$output" == *"hello"* ]]
}

@test "NARROW_LANGUAGE_GLOB_INCLUDE_EXTRA without GLOB_INCLUDE is ignored" {
    echo "hello" > "$WORK/file.yml"
    echo "extra" > "$WORK/file.jsonc"
    printf '%s\n' "place" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    run bash -c "cd '$WORK' && NARROW_LANGUAGE_GLOB_INCLUDE_EXTRA='\.jsonc\$' bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"adding"* ]]
    [[ "$output" == *"hello"* ]]
    [[ "$output" == *"extra"* ]]
}

@test "stages dictionary after modification" {
    echo "hello world" > "$WORK/file.sh"
    printf '%s\n' "hello" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    bash -c "cd '$WORK' && bash '$SCRIPT'"

    run git -C "$WORK" diff --cached --name-only
    [[ "$output" == *".narrow-language.dic"* ]]
}

@test "SHA fragments from 40-char hex strings are not treated as repo words" {
    echo "uses: repo@311740298599dab21f2dc0f83f1d8c974215d197" > "$WORK/ci.yml"
    printf '%s\n' "repo" "uses" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    run bash -c "cd '$WORK' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" != *"dab"* ]]
}

@test "idempotent: second run is a no-op" {
    echo "hello world alpha" > "$WORK/file.sh"
    printf '%s\n' "hello" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    bash -c "cd '$WORK' && bash '$SCRIPT'"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m "after add" --allow-empty

    run bash -c "cd '$WORK' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" != *"adding"* ]]
}

@test "result is sorted and deduplicated" {
    echo "zebra apple apple zebra" > "$WORK/file.sh"
    printf '%s\n' "place" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    bash -c "cd '$WORK' && bash '$SCRIPT'"

    expected=$(printf '%s\n' "apple" "place" "zebra")
    actual=$(cat "$WORK/.narrow-language.dic")
    [ "$actual" = "$expected" ]
}

@test "add then compact is stable" {
    echo "hello world" > "$WORK/file.sh"
    printf '%s\n' "hello" > "$WORK/.narrow-language.dic"
    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m init

    bash -c "cd '$WORK' && bash '$SCRIPT'"
    after_add=$(cat "$WORK/.narrow-language.dic")

    git -C "$WORK" add -A
    git -C "$WORK" commit -q -m "after add"

    COMPACT_SCRIPT="$BATS_TEST_DIRNAME/../../../nix/store/lz851qk8n45hnr2a4xlxw9i43q3k7icd-source/lefthook-narrow-language-compact.sh"
    if [ ! -f "$COMPACT_SCRIPT" ]; then
        skip "compact script not available in nix store"
    fi

    bash -c "cd '$WORK' && bash '$COMPACT_SCRIPT'"
    after_compact=$(cat "$WORK/.narrow-language.dic")

    [ "$after_add" = "$after_compact" ]
}
