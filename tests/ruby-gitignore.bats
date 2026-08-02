#!/usr/bin/env bats

# Contract coverage for the Ruby gitignore standard.

@test "ruby gitignore standard has canonical content" {
    expected="$(printf '%s\n' \
        'vendor/bundle' \
        '.bundle' \
        'coverage' \
        'tmp' \
        '*.gem' \
        '.rspec_status')"

    run cat "$BATS_TEST_DIRNAME/../setting/standards/gitignore/ruby.gitignore"

    [ "$status" -eq 0 ]
    [ "$output" = "$expected" ]
}
