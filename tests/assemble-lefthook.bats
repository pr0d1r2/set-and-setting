#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for setting/lib/assemble-lefthook.sh -- assembles lefthook.yml
# from integration fragments by merging pre-commit + pre-push sections.
# No remotes: block -- all linters are pinned flake checks (#102 FLIP).

write_commands() {
    printf '\n%s\n' "$1:"
    printf '%s\n' "  commands:" \
        "    $2:" "      glob: \"$3\"" \
        "      run: lefthook-$2 {$4}"
}

setup() {
    bats_require_minimum_version 1.5.0
    FRAGMENTS_DIR="$(mktemp -d)"
    _ORIG_FRAGMENTS_DIR="$FRAGMENTS_DIR"
    export out
    out="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/assemble-lefthook.sh"

    {
        printf '%s\n' "---"
        write_commands pre-commit gitleaks "*" staged_files
        write_commands pre-commit git-conflict-markers "*" staged_files
        write_commands pre-commit git-no-local-paths "*" staged_files
    } >"$FRAGMENTS_DIR/base.yml"

    printf '%s\n' "---" >"$FRAGMENTS_DIR/nix.yml"
    printf '%s\n' "---" >"$FRAGMENTS_DIR/shell.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit rubocop "**/*.rb" staged_files
        write_commands pre-push rubocop "**/*.rb" push_files
    } >"$FRAGMENTS_DIR/rubocop.yml"

    {
        printf '%s\n' "---"
        write_commands pre-push rspec "**/*_spec.rb" push_files
    } >"$FRAGMENTS_DIR/rspec.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit reek "**/*.rb" staged_files
        write_commands pre-push reek "**/*.rb" push_files
    } >"$FRAGMENTS_DIR/reek.yml"

    {
        printf '%s\n' "---"
        write_commands pre-push brakeman "**/*.rb" push_files
    } >"$FRAGMENTS_DIR/brakeman.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit bundle-audit "Gemfile.lock" staged_files
        write_commands pre-push bundle-audit "Gemfile.lock" push_files
    } >"$FRAGMENTS_DIR/bundle-audit.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit ascii-check "*.nix" staged_files
        write_commands pre-push ascii-check "*.nix" push_files
    } >"$FRAGMENTS_DIR/ascii.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit mdlint "*.md" staged_files
        write_commands pre-push mdlint "*.md" push_files
    } >"$FRAGMENTS_DIR/markdown.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit yamllint "*.yml" staged_files
        write_commands pre-push yamllint "*.yml" push_files
    } >"$FRAGMENTS_DIR/yaml.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit set-ref-resolution "set/**/*.md" staged_files
        write_commands pre-push set-ref-resolution "set/**/*.md" push_files
    } >"$FRAGMENTS_DIR/set.yml"

    export FRAGMENTS_DIR
}

teardown() {
    rm -rf "$_ORIG_FRAGMENTS_DIR" "$out"
}

@test "produces lefthook.yml" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$out/lefthook.yml" ]
}

@test "output starts with YAML document marker" {
    bash "$SCRIPT"
    head -1 "$out/lefthook.yml" | grep -q '^---$'
}

@test "tracked consumer overrides are extended and merged by lefthook" {
    local workdir
    workdir="$(mktemp -d)"
    git -C "$workdir" init -q
    printf '%s\n' \
        '---' \
        'pre-commit:' \
        '  commands:' \
        '    mdlint:' \
        '      # Broken upstream; see https://example.test/upstream/issues/23.' \
        '      skip: true' >"$workdir/lefthook-overrides.yml"
    cd "$workdir"
    FRAGMENTS="markdown" bash "$SCRIPT"
    cp "$out/lefthook.yml" lefthook.yml

    grep -A1 '^extends:' lefthook.yml | grep -q 'lefthook-overrides.yml'
    run lefthook dump
    [ "$status" -eq 0 ]
    echo "$output" | grep -A3 'mdlint:' | grep -q 'skip: true'
    rm -rf "$workdir"
}

@test "generated config has no dangling override reference" {
    local workdir
    workdir="$(mktemp -d)"
    cd "$workdir"
    bash "$SCRIPT"
    run ! grep -q '^extends:' "$out/lefthook.yml"
    rm -rf "$workdir"
}

@test "no remotes block in output" {
    bash "$SCRIPT"
    run ! grep -q 'remotes:' "$out/lefthook.yml"
    run ! grep -q 'git_url:' "$out/lefthook.yml"
}

@test "has pre-commit section with commands" {
    bash "$SCRIPT"
    grep -q '^pre-commit:' "$out/lefthook.yml"
    grep -q '  commands:' "$out/lefthook.yml"
}

@test "pre-commit merges commands from all fragments" {
    bash "$SCRIPT"
    grep -q 'gitleaks:' "$out/lefthook.yml"
    grep -q 'git-conflict-markers:' "$out/lefthook.yml"
    grep -q 'git-no-local-paths:' "$out/lefthook.yml"
    grep -q 'ascii-check:' "$out/lefthook.yml"
    grep -q 'mdlint:' "$out/lefthook.yml"
    grep -q 'yamllint:' "$out/lefthook.yml"
    grep -q 'set-ref-resolution:' "$out/lefthook.yml"
}

@test "has pre-push section with commands" {
    bash "$SCRIPT"
    grep -q '^pre-push:' "$out/lefthook.yml"
    grep -q 'push_files' "$out/lefthook.yml"
}

@test "pre-push merges commands from all fragments" {
    bash "$SCRIPT"
    local prepush_section
    prepush_section="$(awk '/^pre-push:/,0' "$out/lefthook.yml")"
    echo "$prepush_section" | grep -q 'ascii-check:'
    echo "$prepush_section" | grep -q 'mdlint:'
    echo "$prepush_section" | grep -q 'yamllint:'
    echo "$prepush_section" | grep -q 'set-ref-resolution:'
}

@test "fragments without commands do not add empty sections" {
    for name in base ascii markdown yaml rubocop rspec reek brakeman bundle-audit; do
        printf '%s\n' "---" >"$FRAGMENTS_DIR/$name.yml"
    done
    printf '%s\n' "---" >"$FRAGMENTS_DIR/set.yml"
    bash "$SCRIPT"
    run ! grep -q '^pre-commit:' "$out/lefthook.yml"
    run ! grep -q '^pre-push:' "$out/lefthook.yml"
}

@test "assembles real fragments from setting/integrations/lefthook" {
    local real_dir
    real_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/setting/integrations/lefthook"
    FRAGMENTS_DIR="$real_dir"
    export FRAGMENTS_DIR
    bash "$SCRIPT"
    [ -f "$out/lefthook.yml" ]
    # #102 FLIP: no remotes anywhere in the emitted lefthook.
    run ! grep -q 'remotes:' "$out/lefthook.yml"
    run ! grep -q 'git_url:' "$out/lefthook.yml"
    grep -q '^pre-commit:' "$out/lefthook.yml"
    grep -q '^pre-push:' "$out/lefthook.yml"
    grep -q 'markdownlint:' "$out/lefthook.yml"
    grep -Fq 'run: lefthook-gitleaks {staged_files}' "$out/lefthook.yml"
    grep -Fq 'run: lefthook-git-conflict-markers {staged_files}' \
        "$out/lefthook.yml"
    grep -Fq 'run: lefthook-git-no-local-paths {staged_files}' \
        "$out/lefthook.yml"
    run ! grep -q 'exclude:.*SPEC' "$out/lefthook.yml"
    grep -q 'yamllint:' "$out/lefthook.yml"
    grep -q 'set-ref-resolution:' "$out/lefthook.yml"
    grep -q 'set-bundle-content:' "$out/lefthook.yml"
    grep -q 'rubocop:' "$out/lefthook.yml"
    grep -q 'rspec:' "$out/lefthook.yml"
    grep -q 'reek:' "$out/lefthook.yml"
    grep -q 'brakeman:' "$out/lefthook.yml"
    grep -q 'bundle-audit:' "$out/lefthook.yml"
    grep -q 'bundle exec rspec' "$out/lefthook.yml"
    grep -q 'bundle exec rubocop --fail-fast --force-exclusion {staged_files}' \
        "$out/lefthook.yml"
    awk '
        /^pre-push:/ { push = 1 }
        push && /rubocop:/ { rubocop = 1; next }
        rubocop && /glob: "\*\*\/\*\.rb"/ { found = 1 }
        END { exit !found }
    ' "$out/lefthook.yml"
    run grep -F 'run: bundle exec reek {staged_files}' "$out/lefthook.yml"
    [ "$status" -eq 0 ]
    [ "$output" = '      run: bundle exec reek {staged_files}' ]
    run grep -F 'run: bundle exec bundle-audit check --update' "$out/lefthook.yml"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = '      run: bundle exec bundle-audit check --update' ]
    [ "${lines[1]}" = '      run: bundle exec bundle-audit check --update' ]
}

@test "FRAGMENTS=base+reek includes only reek commands" {
    FRAGMENTS="base reek" bash "$SCRIPT"
    grep -q 'reek:' "$out/lefthook.yml"
    run ! grep -q 'brakeman' "$out/lefthook.yml"
    run ! grep -q 'bundle-audit' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+brakeman includes only brakeman commands" {
    FRAGMENTS="base brakeman" bash "$SCRIPT"
    grep -q 'brakeman:' "$out/lefthook.yml"
    run ! grep -q 'reek' "$out/lefthook.yml"
    run ! grep -q 'bundle-audit' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+bundle-audit includes only bundle-audit commands" {
    FRAGMENTS="base bundle-audit" bash "$SCRIPT"
    grep -q 'bundle-audit:' "$out/lefthook.yml"
    run ! grep -q 'reek' "$out/lefthook.yml"
    run ! grep -q 'brakeman' "$out/lefthook.yml"
}

@test "FRAGMENTS restricts included fragments" {
    FRAGMENTS="base markdown" bash "$SCRIPT"
    grep -q 'mdlint' "$out/lefthook.yml"
    run ! grep -q 'yamllint' "$out/lefthook.yml"
    run ! grep -q 'ascii-check' "$out/lefthook.yml"
    run ! grep -q 'set-ref-resolution' "$out/lefthook.yml"
}

@test "FRAGMENTS=base produces security pre-commit commands" {
    FRAGMENTS="base" bash "$SCRIPT"
    grep -q '^pre-commit:' "$out/lefthook.yml"
    grep -q 'gitleaks:' "$out/lefthook.yml"
    grep -q 'git-conflict-markers:' "$out/lefthook.yml"
    grep -q 'git-no-local-paths:' "$out/lefthook.yml"
    run ! grep -q '^pre-push:' "$out/lefthook.yml"
    run ! grep -q 'remotes:' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+ascii includes ascii commands" {
    FRAGMENTS="base ascii" bash "$SCRIPT"
    grep -q 'ascii-check:' "$out/lefthook.yml"
    run ! grep -q 'yamllint' "$out/lefthook.yml"
}

@test "FRAGMENTS with real fragments -- nix only" {
    local real_dir
    real_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/setting/integrations/lefthook"
    FRAGMENTS_DIR="$real_dir"
    export FRAGMENTS_DIR
    FRAGMENTS="base nix ascii" bash "$SCRIPT"
    # #102 FLIP: no remotes from any fragment.
    run ! grep -q 'remotes:' "$out/lefthook.yml"
    run ! grep -q 'git_url:' "$out/lefthook.yml"
    run ! grep -q 'nix-lefthook-markdownlint' "$out/lefthook.yml"
    run ! grep -q 'nix-lefthook-yamllint' "$out/lefthook.yml"
    run ! grep -q 'set-ref-resolution' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+set includes set commands" {
    FRAGMENTS="base set" bash "$SCRIPT"
    grep -q 'set-ref-resolution:' "$out/lefthook.yml"
    run ! grep -q 'mdlint' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+rubocop includes only rubocop commands" {
    FRAGMENTS="base rubocop" bash "$SCRIPT"
    grep -q 'rubocop:' "$out/lefthook.yml"
    run ! grep -q 'mdlint' "$out/lefthook.yml"
    run ! grep -q 'yamllint' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+rspec includes only rspec commands" {
    FRAGMENTS="base rspec" bash "$SCRIPT"
    grep -q 'rspec:' "$out/lefthook.yml"
    run ! grep -q 'rubocop' "$out/lefthook.yml"
    run ! grep -q 'mdlint' "$out/lefthook.yml"
    run ! grep -q 'yamllint' "$out/lefthook.yml"
}

@test "no remotes even with set-only fragment" {
    FRAGMENTS="set" bash "$SCRIPT"
    run ! grep -q 'remotes:' "$out/lefthook.yml"
    run ! grep -q 'git_url:' "$out/lefthook.yml"
}

@test "set fragment commands in pre-commit and pre-push" {
    FRAGMENTS="base set" bash "$SCRIPT"
    local precommit_section prepush_section
    precommit_section="$(awk '/^pre-commit:/,/^pre-push:/' "$out/lefthook.yml")"
    prepush_section="$(awk '/^pre-push:/,0' "$out/lefthook.yml")"
    echo "$precommit_section" | grep -q 'set-ref-resolution:'
    echo "$prepush_section" | grep -q 'set-ref-resolution:'
}

@test "real set fragment includes both checks" {
    local real_dir
    real_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/setting/integrations/lefthook"
    FRAGMENTS_DIR="$real_dir"
    export FRAGMENTS_DIR
    FRAGMENTS="base set" bash "$SCRIPT"
    grep -q 'set-ref-resolution:' "$out/lefthook.yml"
    grep -q 'set-bundle-content:' "$out/lefthook.yml"
    grep -q 'ref-resolve-check.sh' "$out/lefthook.yml"
    grep -q 'bundle-content-check.sh' "$out/lefthook.yml"
}

# ======== repo-local fragment (#126) ========

@test "lefthook-repo.yml in CWD is included in assembly" {
    local workdir
    workdir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit taplo "*.toml" staged_files
        write_commands pre-push taplo "*.toml" push_files
    } >"$workdir/lefthook-repo.yml"
    cd "$workdir"
    bash "$SCRIPT"
    grep -q 'taplo:' "$out/lefthook.yml"
    grep -q 'lefthook-taplo' "$out/lefthook.yml"
    # standard fragment commands also present
    grep -q 'ascii-check:' "$out/lefthook.yml"
    grep -q 'mdlint:' "$out/lefthook.yml"
    rm -rf "$workdir"
}

@test "repo-local pre-commit commands merge with standard fragments" {
    local workdir
    workdir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit taplo "*.toml" staged_files
    } >"$workdir/lefthook-repo.yml"
    cd "$workdir"
    bash "$SCRIPT"
    local precommit_section
    precommit_section="$(awk '/^pre-commit:/,/^pre-push:/' "$out/lefthook.yml")"
    echo "$precommit_section" | grep -q 'taplo:'
    echo "$precommit_section" | grep -q 'ascii-check:'
    rm -rf "$workdir"
}

@test "repo-local pre-push commands merge with standard fragments" {
    local workdir
    workdir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-push taplo "*.toml" push_files
    } >"$workdir/lefthook-repo.yml"
    cd "$workdir"
    bash "$SCRIPT"
    local prepush_section
    prepush_section="$(awk '/^pre-push:/,0' "$out/lefthook.yml")"
    echo "$prepush_section" | grep -q 'taplo:'
    echo "$prepush_section" | grep -q 'ascii-check:'
    rm -rf "$workdir"
}

@test "no lefthook-repo.yml means no repo-local commands" {
    local workdir
    workdir="$(mktemp -d)"
    cd "$workdir"
    bash "$SCRIPT"
    run ! grep -q 'taplo' "$out/lefthook.yml"
    rm -rf "$workdir"
}

@test "repo-local fragment alone creates hook sections" {
    # All standard fragments empty -- repo-local is the only source
    for name in base nix shell rubocop rspec reek brakeman bundle-audit ascii markdown yaml set; do
        printf '%s\n' "---" >"$FRAGMENTS_DIR/$name.yml"
    done
    local workdir
    workdir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit taplo "*.toml" staged_files
    } >"$workdir/lefthook-repo.yml"
    cd "$workdir"
    bash "$SCRIPT"
    grep -q '^pre-commit:' "$out/lefthook.yml"
    grep -q 'taplo:' "$out/lefthook.yml"
    rm -rf "$workdir"
}

# ======== migration overlay (#281) ========

@test "MIGRATION_HAS_OVERLAY adds extends reference for lefthook-migration.yml" {
    MIGRATION_HAS_OVERLAY=1 bash "$SCRIPT"
    grep -q '^extends:' "$out/lefthook.yml"
    grep -q 'lefthook-migration.yml' "$out/lefthook.yml"
}

@test "MIGRATION_HAS_OVERLAY=1 with overrides emits both extends entries" {
    local workdir
    workdir="$(mktemp -d)"
    printf '%s\n' '---' 'pre-commit:' '  commands:' '    mdlint:' '      skip: true' \
        >"$workdir/lefthook-overrides.yml"
    cd "$workdir"
    MIGRATION_HAS_OVERLAY=1 bash "$SCRIPT"
    grep -q 'lefthook-overrides.yml' "$out/lefthook.yml"
    grep -q 'lefthook-migration.yml' "$out/lefthook.yml"
    rm -rf "$workdir"
}

@test "no MIGRATION_HAS_OVERLAY means no migration extends reference" {
    bash "$SCRIPT"
    run ! grep -q 'lefthook-migration.yml' "$out/lefthook.yml"
}

@test "MIGRATION_SKIPS injects skip:true for named commands" {
    MIGRATION_SKIPS="gitleaks" bash "$SCRIPT"
    # skip:true must appear on the line immediately after gitleaks:
    grep -A1 '    gitleaks:$' "$out/lefthook.yml" | grep -q 'skip: true'
}

@test "MIGRATION_SKIPS with multiple commands skips all" {
    MIGRATION_SKIPS="gitleaks git-conflict-markers" bash "$SCRIPT"
    grep -A1 '    gitleaks:$' "$out/lefthook.yml" | grep -q 'skip: true'
    grep -A1 '    git-conflict-markers:$' "$out/lefthook.yml" | grep -q 'skip: true'
    # Unskipped command should NOT have skip:true
    ! grep -A1 '    git-no-local-paths:$' "$out/lefthook.yml" | grep -q 'skip: true'
}

@test "MIGRATION_SKIPS without MIGRATION_HAS_OVERLAY still injects skips" {
    MIGRATION_SKIPS="gitleaks" bash "$SCRIPT"
    grep -A1 '    gitleaks:$' "$out/lefthook.yml" | grep -q 'skip: true'
    run ! grep -q 'lefthook-migration.yml' "$out/lefthook.yml"
}

@test "empty MIGRATION_SKIPS does not inject any skips" {
    MIGRATION_SKIPS="" bash "$SCRIPT"
    run ! grep -q 'skip: true' "$out/lefthook.yml"
}

# ======== migration overlay assembly (#281) ========

@test "migration overlay assembler produces lefthook-migration.yml" {
    local overlay_dir
    overlay_dir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit vulnix-scan "*.nix" staged_files
    } >"$overlay_dir/nix.yml"
    MIGRATION_OVERLAY_DIR="$overlay_dir" \
        FRAGMENTS="nix" \
        bash "$BATS_TEST_DIRNAME/../setting/lib/assemble-migration-overlay.sh"
    [ -f "$out/lefthook-migration.yml" ]
    rm -rf "$overlay_dir"
}

@test "migration overlay starts with YAML marker and advisory header" {
    local overlay_dir
    overlay_dir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit vulnix-scan "*.nix" staged_files
    } >"$overlay_dir/nix.yml"
    MIGRATION_OVERLAY_DIR="$overlay_dir" \
        FRAGMENTS="nix" \
        bash "$BATS_TEST_DIRNAME/../setting/lib/assemble-migration-overlay.sh"
    head -1 "$out/lefthook-migration.yml" | grep -q '^---$'
    grep -q 'advisory' "$out/lefthook-migration.yml"
    rm -rf "$overlay_dir"
}

@test "migration overlay wraps run commands with advisory exit" {
    local overlay_dir
    overlay_dir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit vulnix-scan "*.nix" staged_files
    } >"$overlay_dir/nix.yml"
    MIGRATION_OVERLAY_DIR="$overlay_dir" \
        FRAGMENTS="nix" \
        bash "$BATS_TEST_DIRNAME/../setting/lib/assemble-migration-overlay.sh"
    # The run line should end with "; true" for advisory non-blocking mode
    grep -q 'run: lefthook-vulnix-scan {staged_files}; true' \
        "$out/lefthook-migration.yml"
    rm -rf "$overlay_dir"
}

@test "migration overlay merges pre-commit and pre-push" {
    local overlay_dir
    overlay_dir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit vulnix-scan "*.nix" staged_files
        write_commands pre-push vulnix-scan "*.nix" push_files
    } >"$overlay_dir/nix.yml"
    MIGRATION_OVERLAY_DIR="$overlay_dir" \
        FRAGMENTS="nix" \
        bash "$BATS_TEST_DIRNAME/../setting/lib/assemble-migration-overlay.sh"
    grep -q '^pre-commit:' "$out/lefthook-migration.yml"
    grep -q '^pre-push:' "$out/lefthook-migration.yml"
    # Both sections should have advisory wrapping
    local precommit_run prepush_run
    precommit_run="$(awk '/^pre-commit:/,/^pre-push:/' "$out/lefthook-migration.yml" | grep 'run:')"
    prepush_run="$(awk '/^pre-push:/,0' "$out/lefthook-migration.yml" | grep 'run:')"
    echo "$precommit_run" | grep -q '; true'
    echo "$prepush_run" | grep -q '; true'
    rm -rf "$overlay_dir"
}

@test "migration overlay respects FRAGMENTS filter" {
    local overlay_dir
    overlay_dir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit vulnix-scan "*.nix" staged_files
    } >"$overlay_dir/nix.yml"
    {
        printf '%s\n' "---"
        write_commands pre-commit new-mdlint "*.md" staged_files
    } >"$overlay_dir/markdown.yml"
    MIGRATION_OVERLAY_DIR="$overlay_dir" \
        FRAGMENTS="nix" \
        bash "$BATS_TEST_DIRNAME/../setting/lib/assemble-migration-overlay.sh"
    grep -q 'vulnix-scan' "$out/lefthook-migration.yml"
    run ! grep -q 'new-mdlint' "$out/lefthook-migration.yml"
    rm -rf "$overlay_dir"
}

@test "migration overlay skips missing fragment files" {
    local overlay_dir
    overlay_dir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit vulnix-scan "*.nix" staged_files
    } >"$overlay_dir/nix.yml"
    # No base.yml in overlay -- should not error
    MIGRATION_OVERLAY_DIR="$overlay_dir" \
        bash "$BATS_TEST_DIRNAME/../setting/lib/assemble-migration-overlay.sh"
    [ -f "$out/lefthook-migration.yml" ]
    grep -q 'vulnix-scan' "$out/lefthook-migration.yml"
    rm -rf "$overlay_dir"
}

@test "migration overlay with no matching fragments produces header-only file" {
    local overlay_dir
    overlay_dir="$(mktemp -d)"
    MIGRATION_OVERLAY_DIR="$overlay_dir" \
        FRAGMENTS="base" \
        bash "$BATS_TEST_DIRNAME/../setting/lib/assemble-migration-overlay.sh"
    [ -f "$out/lefthook-migration.yml" ]
    head -1 "$out/lefthook-migration.yml" | grep -q '^---$'
    run ! grep -q '^pre-commit:' "$out/lefthook-migration.yml"
    run ! grep -q '^pre-push:' "$out/lefthook-migration.yml"
    rm -rf "$overlay_dir"
}

@test "full expand: main skips + overlay advisory + extends wired" {
    local overlay_dir
    overlay_dir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit new-gitleaks "*.nix" staged_files
    } >"$overlay_dir/base.yml"
    # Assemble main with skips and overlay reference
    MIGRATION_SKIPS="gitleaks" \
        MIGRATION_HAS_OVERLAY=1 \
        bash "$SCRIPT"
    # Assemble overlay
    MIGRATION_OVERLAY_DIR="$overlay_dir" \
        FRAGMENTS="base" \
        bash "$BATS_TEST_DIRNAME/../setting/lib/assemble-migration-overlay.sh"
    # Main: gitleaks skipped, extends migration overlay
    grep -A1 '    gitleaks:$' "$out/lefthook.yml" | grep -q 'skip: true'
    grep -q 'lefthook-migration.yml' "$out/lefthook.yml"
    # Overlay: new-gitleaks advisory
    grep -q 'new-gitleaks' "$out/lefthook-migration.yml"
    grep -q '; true' "$out/lefthook-migration.yml"
    rm -rf "$overlay_dir"
}

@test "no migration state produces identical output to pre-281 behavior" {
    # Without any MIGRATION_ env vars, output is unchanged
    bash "$SCRIPT"
    local baseline
    baseline="$(cat "$out/lefthook.yml")"
    rm -f "$out/lefthook.yml"
    MIGRATION_SKIPS="" MIGRATION_HAS_OVERLAY="" bash "$SCRIPT"
    local with_empty
    with_empty="$(cat "$out/lefthook.yml")"
    [ "$baseline" = "$with_empty" ]
}
