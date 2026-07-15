#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for lib/migrate.sh -- vendored->referenced transform (#96).
# Covers pre-flight checks (#115), state detection (including sub-classified
# partial states), strip, plant, gitignore-merge, the check-set equivalence
# gate, custom flake detection, extra workflow preservation, idempotency,
# and the dry-run/detect modes.

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

# helper: init a git repo with an initial commit (satisfies pre-flight)
_init_repo() {
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    git add .
    git commit -q -m "initial" --allow-empty
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

# a vendored lefthook carrying a `remotes:` block (git_url/ref/configs list
# fields) ALONGSIDE its real inline command -- the remotes fields share the
# 4-space indent of command keys but are NOT checks. The equivalence parser
# must scope to the `commands:` block and ignore ref/configs (#regression).
write_vendored_lefthook_with_remotes() {
    printf '%s\n' \
        "---" \
        "remotes:" \
        "  - git_url: https://github.com/pr0d1r2/nix-lefthook-nixfmt" \
        "    ref: main" \
        "    configs:" \
        "      - lefthook-remote.yml" \
        "pre-commit:" \
        "  parallel: true" \
        "  commands:" \
        "    nixfmt:" \
        "      run: nixfmt --check {staged_files}" \
        >lefthook.yml
}

# ======== pre-flight checks (#115) ========

@test "pre-flight: rejects non-git-repo with MIGRATE-FAIL" {
    mkdir not-a-repo && cd not-a-repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=pre-flight reason=not-a-git-repo"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

@test "pre-flight: rejects repo with no commits with MIGRATE-FAIL" {
    git init -q
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=pre-flight reason=no-commits"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

@test "pre-flight: rejects detached HEAD with MIGRATE-FAIL" {
    echo "# readme" >README.md
    _init_repo
    # detach HEAD
    git checkout --detach HEAD 2>/dev/null
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=pre-flight reason=detached-head"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

@test "pre-flight: rejects dirty worktree with MIGRATE-FAIL" {
    echo "# readme" >README.md
    _init_repo
    echo "uncommitted" >dirty.txt
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=pre-flight reason=dirty-worktree"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

# ======== state detection ========

@test "detects vendored state (heavy flake + tracked lefthook)" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    _init_repo
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=vendored"* ]]
}

@test "detects bare state (no flake, no lefthook)" {
    echo "# readme" >README.md
    _init_repo
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=bare"* ]]
}

@test "detects referenced state (seed layout) and is a no-op" {
    cp -r "$SEED_SRC/." .
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=referenced"* ]]
    [[ "$output" == *"no-op"* ]]
}

# ======== sub-classified partial states (#115) ========

@test "detects partial-tracked-lefthook (referenced flake but tracked lefthook)" {
    cp -r "$SEED_SRC/." .
    write_vendored_lefthook
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    git add -f lefthook.yml
    git add .
    git commit -q -m "initial"
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=partial-tracked-lefthook"* ]]
}

@test "detects partial-no-gitignore (references SNS but no lefthook gitignore)" {
    printf '%s\n' \
        "{" \
        "  inputs.set-and-setting.url = \"github:pr0d1r2/set-and-setting\";" \
        "}" \
        >flake.nix
    echo "# no lefthook.yml entry" >.gitignore
    _init_repo
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=partial-no-gitignore"* ]]
}

@test "detects partial-no-materialization (references SNS without checksFor)" {
    printf '%s\n' \
        "{" \
        "  inputs.set-and-setting.url = \"github:pr0d1r2/set-and-setting\";" \
        "}" \
        >flake.nix
    printf '%s\n' "lefthook.yml" >.gitignore
    _init_repo
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=partial-no-materialization"* ]]
}

# ======== custom flake detection (#115) ========

@test "custom flake with extra inputs emits MIGRATE-FAIL" {
    printf '%s\n' \
        "{" \
        "  inputs.my-overlay.url = \"github:example/overlay\";" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=detect reason=custom-flake"* ]]
    [[ "$output" == *"extra inputs: my-overlay"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

@test "custom flake with overlays emits MIGRATE-FAIL" {
    printf '%s\n' \
        "{" \
        "  outputs = { self }: {" \
        "    overlays.default = final: prev: { };" \
        "  };" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=detect reason=custom-flake"* ]]
    [[ "$output" == *"overlays detected"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

@test "custom flake with extra outputs emits MIGRATE-FAIL" {
    printf '%s\n' \
        "{" \
        "  outputs = { self }: {" \
        "    nixosConfigurations.test = { };" \
        "  };" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=detect reason=custom-flake"* ]]
    [[ "$output" == *"extra outputs detected"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

# ======== extra workflow handling (#115) ========

@test "extra workflows are preserved during transform" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    mkdir -p .github/workflows
    echo "vendored ci" >.github/workflows/ci.yml
    echo "deploy workflow" >.github/workflows/deploy.yml
    echo "release workflow" >.github/workflows/release.yml
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"extra workflows detected (will preserve)"* ]]
    [[ "$output" == *"deploy.yml"* ]]
    [[ "$output" == *"release.yml"* ]]
    # extra workflows untouched
    [ -f .github/workflows/deploy.yml ]
    [ -f .github/workflows/release.yml ]
    grep -q "deploy workflow" .github/workflows/deploy.yml
    grep -q "release workflow" .github/workflows/release.yml
    # vendored ci.yml replaced
    grep -q "guardrails.yml" .github/workflows/ci.yml
}

@test "extra workflows flagged in detect-only mode" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    mkdir -p .github/workflows
    echo "vendored ci" >.github/workflows/ci.yml
    echo "custom workflow" >.github/workflows/custom.yml
    _init_repo
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"extra workflows detected (will preserve): custom.yml"* ]]
}

@test "extra workflows listed in dry-run plan" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    mkdir -p .github/workflows
    echo "vendored ci" >.github/workflows/ci.yml
    echo "test workflow" >.github/workflows/test.yml
    _init_repo
    MIGRATE_DRY_RUN=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"preserve: extra workflows (test.yml)"* ]]
}

# ======== transform ========

@test "vendored transform strips artifacts and plants the seed" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    mkdir -p .github/workflows
    echo "vendored ci" >.github/workflows/ci.yml
    _init_repo
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
    _init_repo
    bash "$MIGRATE_SCRIPT"
    hash1="$(sha256sum flake.nix | cut -d' ' -f1)"
    git add -A
    git commit -q -m "migrated" --allow-empty
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"no-op"* ]]
    hash2="$(sha256sum flake.nix | cut -d' ' -f1)"
    [ "$hash1" = "$hash2" ]
}

@test "partial-tracked-lefthook completes the migration" {
    cp -r "$SEED_SRC/." .
    write_vendored_lefthook
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    git add -f lefthook.yml
    git add .
    git commit -q -m "initial"
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=partial-tracked-lefthook"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    ! git ls-files | grep -qxF "lefthook.yml"
}

# ======== equivalence gate ========

@test "equivalence gate carries through a repo-local check (#126)" {
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
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"carried-through: super-special-check"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    [ -f lefthook-repo.yml ]
    grep -q 'super-special-check:' lefthook-repo.yml
    grep -q 'our-bespoke-linter' lefthook-repo.yml
    grep -q 'super-special-check:' lefthook.yml
}

@test "equivalence gate classifies a standard-fragment dropped check" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    markdownlint:" \
        "      run: markdownlint {staged_files}" \
        >lefthook.yml
    _init_repo
    # strip FULL_LEFTHOOK so markdownlint is not in the universe
    # (markdownlint is lefthook-only, not in CHECKS_UNIVERSE)
    FULL_LEFTHOOK="" run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=equivalence reason=uncovered-checks"* ]]
    [[ "$output" == *"dropped:"*"markdownlint"* ]]
    [[ "$output" == *"standard fragment \`markdown\` covers this"* ]]
    [[ "$output" == *"tracked *.md files"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

@test "equivalence gate ignores remotes ref/configs fields (not checks)" {
    # A vendored lefthook with a `remotes:` block: its `ref:`/`configs:`
    # list fields sit at 4-space indent (like command keys) but are NOT
    # lefthook checks. The old grep-based parser mistook them for dropped
    # checks and failed every migration. The command-scoped extractor must
    # see ONLY the real `nixfmt` command (covered by CHECKS_UNIVERSE).
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook_with_remotes
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS: equivalence"* ]]
    # the remotes-field false-positives must NOT appear as dropped checks
    [[ "$output" != *"dropped:"*"ref"* ]]
    [[ "$output" != *"dropped:"*"configs"* ]]
    [[ "$output" != *"dropped:"*"git_url"* ]]
    [[ "$output" != *"MIGRATE-FAIL"* ]]
}

# ======== carry-through: repo-local checks (#126) ========

@test "carry-through: self-hosting repo migrates with repo-local check preserved" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    nixfmt:" \
        "      run: nixfmt --check {staged_files}" \
        "    taplo:" \
        "      run: lefthook-taplo --check {staged_files}" \
        "      glob: \"*.toml\"" \
        >lefthook.yml
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"carried-through: taplo"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # lefthook-repo.yml created and tracked
    [ -f lefthook-repo.yml ]
    git ls-files | grep -qxF "lefthook-repo.yml"
    grep -q 'taplo:' lefthook-repo.yml
    # taplo appears in the materialized lefthook.yml
    grep -q 'taplo:' lefthook.yml
}

@test "carry-through: plain consumer with only standard checks is unaffected" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS: equivalence"* ]]
    [[ "$output" != *"carried-through"* ]]
    # no lefthook-repo.yml created
    [ ! -f lefthook-repo.yml ]
}

@test "carry-through: pre-push repo-local check also carried" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    nixfmt:" \
        "      run: nixfmt --check {staged_files}" \
        "    taplo:" \
        "      run: lefthook-taplo --check {staged_files}" \
        "      glob: \"*.toml\"" \
        "pre-push:" \
        "  commands:" \
        "    taplo:" \
        "      run: lefthook-taplo {push_files}" \
        "      glob: \"*.toml\"" \
        >lefthook.yml
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"carried-through: taplo"* ]]
    # both hooks present in repo-local fragment
    grep -q 'pre-commit:' lefthook-repo.yml
    grep -q 'pre-push:' lefthook-repo.yml
    # both hooks have taplo in materialized lefthook.yml
    local precommit_section prepush_section
    precommit_section="$(awk '/^pre-commit:/,/^pre-push:/' lefthook.yml)"
    prepush_section="$(awk '/^pre-push:/,0' lefthook.yml)"
    echo "$precommit_section" | grep -q 'taplo:'
    echo "$prepush_section" | grep -q 'taplo:'
}

@test "carry-through: multiple repo-local checks all carried" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    nixfmt:" \
        "      run: nixfmt --check {staged_files}" \
        "    taplo:" \
        "      run: lefthook-taplo --check {staged_files}" \
        "    custom-lint:" \
        "      run: custom-linter {staged_files}" \
        >lefthook.yml
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"carried-through:"* ]]
    [[ "$output" == *"taplo"* ]]
    [[ "$output" == *"custom-lint"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    grep -q 'taplo:' lefthook-repo.yml
    grep -q 'custom-lint:' lefthook-repo.yml
}

@test "carry-through: standard-fragment drop still fails even with repo-local carry" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    taplo:" \
        "      run: lefthook-taplo --check {staged_files}" \
        "    markdownlint:" \
        "      run: markdownlint {staged_files}" \
        >lefthook.yml
    _init_repo
    # strip FULL_LEFTHOOK so markdownlint is not in the universe
    FULL_LEFTHOOK="" run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=equivalence reason=uncovered-checks"* ]]
    [[ "$output" == *"dropped:"*"markdownlint"* ]]
    # taplo was carried through but markdownlint still fails
    [[ "$output" == *"carried-through: taplo"* ]]
}

@test "equivalence gate carries through repo-local command beside a remotes block" {
    # A repo-local command under `commands:` alongside a `remotes:` block
    # is carried through (#126); remotes fields are still excluded.
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "remotes:" \
        "  - git_url: https://github.com/pr0d1r2/nix-lefthook-nixfmt" \
        "    ref: main" \
        "    configs:" \
        "      - lefthook-remote.yml" \
        "pre-commit:" \
        "  commands:" \
        "    super-special-check:" \
        "      run: our-bespoke-linter" \
        >lefthook.yml
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"carried-through: super-special-check"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # only the expected check was carried through (not remotes fields)
    local carried_line
    carried_line="$(echo "$output" | grep 'carried-through:')"
    [[ "$carried_line" == "carried-through: super-special-check"* ]]
    echo "$carried_line" | run ! grep -qw 'ref'
    echo "$carried_line" | run ! grep -qw 'configs'
    echo "$carried_line" | run ! grep -qw 'git_url'
    # repo-local fragment created
    [ -f lefthook-repo.yml ]
    grep -q 'super-special-check:' lefthook-repo.yml
    grep -q 'our-bespoke-linter' lefthook-repo.yml
}

# ======== stage-trap (#115) ========

@test "mid-stage abort emits MIGRATE-FAIL with reason=unexpected" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    nixfmt:" \
        "      run: nixfmt --check {staged_files}" \
        >lefthook.yml
    _init_repo
    # point DETECT_SCRIPT at a script that fails during the materialize stage
    failing_script="$(mktemp)"
    printf '#!/usr/bin/env bash\nexit 1\n' >"$failing_script"
    chmod +x "$failing_script"
    DETECT_SCRIPT="$failing_script" run bash "$MIGRATE_SCRIPT"
    rm -f "$failing_script"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=materialize reason=unexpected"* ]]
    [[ "$output" == *"resolution:"* ]]
    [[ "$output" == *"backprop issue"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

# ======== gitignore / dry-run / detect-only ========

@test "gitignore-merge appends materialized entries to an existing .gitignore" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    printf '%s\n' "node_modules/" >.gitignore
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    grep -qxF "node_modules/" .gitignore
    grep -qxF "lefthook.yml" .gitignore
    grep -qxF ".markdownlint.yml" .gitignore
}

@test "--dry-run reports the plan and writes nothing" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    _init_repo
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
    _init_repo
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=vendored"* ]]
    # nothing stripped
    [ -f lefthook.yml ]
    grep -q "outputs = { self }" flake.nix
}
