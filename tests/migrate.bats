#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for lib/migrate.sh -- vendored->referenced transform (#96).
# Covers state detection, strip, plant, gitignore-merge, the check-set
# equivalence gate, idempotency, and the dry-run/detect modes.

setup() {
    bats_require_minimum_version 1.5.0
    REPO_ROOT="$BATS_TEST_DIRNAME/.."
    export MIGRATE_SCRIPT="$REPO_ROOT/lib/migrate.sh"
    export FRAGMENTS_DIR="$REPO_ROOT/setting/integrations/lefthook"
    export ASSEMBLE_SCRIPT="$REPO_ROOT/setting/lib/assemble-lefthook.sh"
    export DETECT_SCRIPT="$REPO_ROOT/setting/lib/detect-fragments.sh"
    export CONFIRM_SCRIPT="$REPO_ROOT/lib/confirm.sh"
    export CONFIRM_REV="test-rev"
    export CHECKS_UNIVERSE="nixfmt statix deadnix shellcheck gitleaks shfmt typos ascii-only editorconfig-checker execute-permissions file-size-check git-conflict-markers git-no-local-paths missing-final-newline nix-no-embedded-shell no-shell-functions trailing-whitespace"

    # a materialized config bundle (SETTING_SRC)
    SETTING_SRC="$(mktemp -d)"
    echo "markdownlint config" >"$SETTING_SRC/.markdownlint.yml"
    echo "yamllint config" >"$SETTING_SRC/.yamllint.yml"
    export SETTING_SRC

    # a leaf seed (SEED_SRC): thin referenced flake + gitignore + CI caller
    SEED_SRC="$(mktemp -d)"
    mkdir -p "$SEED_SRC/.github/workflows"
    # a referenced (thin) flake: names set-and-setting + the materialization
    # helpers (checksFor / materializationFor) that mark it as referenced
    printf '%s\n' \
        "{" \
        "  inputs.set-and-setting.url = \"github:pr0d1r2/set-and-setting\";" \
        "  # uses checksFor + materializationFor" \
        "}" \
        >"$SEED_SRC/flake.nix"
    printf '%s\n' ".direnv/" "result" ".markdownlint.yml" ".yamllint.yml" "lefthook.yml" >"$SEED_SRC/.gitignore"
    printf '%s\n' "jobs:" "  guardrails:" "    uses: pr0d1r2/set-and-setting/.github/workflows/guardrails.yml@main" >"$SEED_SRC/.github/workflows/ci.yml"
    echo "auto-update" >"$SEED_SRC/.github/workflows/auto-update.yml"
    export SEED_SRC

    # FULL_LEFTHOOK: assembled from all fragments (command-name universe)
    FULL_DIR="$(mktemp -d)"
    FRAGMENTS="base nix shell ascii markdown yaml set" out="$FULL_DIR" \
        bash "$ASSEMBLE_SCRIPT"
    export FULL_LEFTHOOK="$FULL_DIR/lefthook.yml"

    WORK="$(mktemp -d)"
    cd "$WORK" || exit 1
}

teardown() {
    cd /
    rm -rf "$SEED_SRC" "$SETTING_SRC" "$FULL_DIR" "$WORK"
}

# a vendored (pre-FLIP) lefthook: guardrails inline as commands (all covered)
write_vendored_lefthook() {
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    nixfmt:" \
        "      run: nixfmt --check {staged_files}" \
        "    shellcheck:" \
        "      run: shellcheck {staged_files}" \
        "    markdownlint:" \
        "      run: markdownlint {staged_files}" \
        >lefthook.yml
}

@test "detects vendored state (heavy flake + tracked lefthook)" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    git init -q
    git add .
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=vendored"* ]]
}

@test "detects bare state (no flake, no lefthook)" {
    echo "# readme" >README.md
    git init -q
    git add .
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=bare"* ]]
}

@test "detects referenced state (seed layout) and is a no-op" {
    cp -r "$SEED_SRC/." .
    git init -q
    git add .
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=referenced"* ]]
    [[ "$output" == *"no-op"* ]]
}

@test "detects partial state (referenced flake but tracked lefthook)" {
    cp -r "$SEED_SRC/." .
    write_vendored_lefthook
    git init -q
    git add -f lefthook.yml
    git add .
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=partial"* ]]
}

@test "vendored transform strips artifacts and plants the seed" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    mkdir -p .github/workflows
    echo "vendored ci" >.github/workflows/ci.yml
    git init -q
    git add .
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS: equivalence"* ]]
    # thin referenced flake planted
    grep -q "set-and-setting" flake.nix
    grep -q "checksFor" flake.nix
    # ci.yml replaced by guardrails caller
    grep -q "guardrails.yml" .github/workflows/ci.yml
    # lefthook.yml now gitignored, no longer tracked
    grep -qxF "lefthook.yml" .gitignore
    ! git ls-files | grep -qxF "lefthook.yml"
}

@test "transform is idempotent (re-run is a no-op)" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    git init -q
    git add .
    bash "$MIGRATE_SCRIPT"
    hash1="$(sha256sum flake.nix | cut -d' ' -f1)"
    git add -A
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"no-op"* ]]
    hash2="$(sha256sum flake.nix | cut -d' ' -f1)"
    [ "$hash1" = "$hash2" ]
}

@test "equivalence gate rejects a dropped vendored check" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    nixfmt:" \
        "      run: nixfmt --check {staged_files}" \
        "    super-special-check:" \
        "      run: our-bespoke-linter" \
        >lefthook.yml
    git init -q
    git add .
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"DROPS vendored checks"* ]]
    [[ "$output" == *"super-special-check"* ]]
}

@test "gitignore-merge appends materialized entries to an existing .gitignore" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    printf '%s\n' "node_modules/" >.gitignore
    git init -q
    git add .
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    grep -qxF "node_modules/" .gitignore
    grep -qxF "lefthook.yml" .gitignore
    grep -qxF ".markdownlint.yml" .gitignore
}

@test "--dry-run reports the plan and writes nothing" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    git init -q
    git add .
    before="$(sha256sum flake.nix | cut -d' ' -f1)"
    MIGRATE_DRY_RUN=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run plan"* ]]
    [[ "$output" == *"strip: lefthook.yml"* ]]
    after="$(sha256sum flake.nix | cut -d' ' -f1)"
    [ "$before" = "$after" ]
    # still the vendored flake (not transformed)
    grep -q "outputs = { self }" flake.nix
}

@test "detect-only prints state without transforming" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    git init -q
    git add .
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=vendored"* ]]
    # nothing stripped
    [ -f lefthook.yml ]
    grep -q "outputs = { self }" flake.nix
}
