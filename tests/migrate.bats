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
    export CHECK_FRAGMENT_MAP="gitleaks=base git-conflict-markers=base git-no-local-paths=base execute-permissions=base file-size-check=base trailing-whitespace=base missing-final-newline=base editorconfig-checker=base typos=base nixfmt=nix statix=nix deadnix=nix nix-no-embedded-shell=nix shellcheck=shell shfmt=shell no-shell-functions=shell ascii-only=ascii markdownlint=markdown markdownlint-agentic=markdown yamllint=yaml set-skill-extension=set set-skill-size=set set-ref-resolution=set set-bundle-content=set"

    # a materialized config bundle (SETTING_SRC)
    SETTING_SRC="$(mktemp -d)"
    echo "markdownlint config" >"$SETTING_SRC/.markdownlint.yml"
    echo "yamllint config" >"$SETTING_SRC/.yamllint.yml"
    export SETTING_SRC

    # a leaf seed (SEED_SRC): thin referenced flake + gitignore + CI caller
    SEED_SRC="$(mktemp -d)"
    mkdir -p "$SEED_SRC/.github/workflows"
    # a referenced (thin) flake: names set-and-setting + the materialization
    # helpers (checksFor / materializationFor) that mark it as referenced.
    # Structure mirrors leaf-flake.txt with injection points for reconciliation:
    # set-and-setting.url (custom inputs), set-and-setting, (output args),
    # closing    }; (custom outputs), a fragments declaration, and an inner
    # let...in (devShells) to verify let-binding injection targets only the
    # outer let block.
    printf '%s\n' \
        "{" \
        "  inputs = {" \
        "    nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "    nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "" \
        "    set-and-setting.url = \"github:pr0d1r2/set-and-setting\";" \
        "  };" \
        "" \
        "  outputs =" \
        "    {" \
        "      self," \
        "      nixpkgs," \
        "      set-and-setting," \
        "      ..." \
        "    }:" \
        "    let" \
        "      fragments = [" \
        "        \"base\"" \
        "        \"nix\"" \
        "      ];" \
        "    in" \
        "    {" \
        "      packages = forAllSystems (pkgs: {" \
        "        setting = (set-and-setting.lib.mkSetting { inherit pkgs; }).materialized;" \
        "      });" \
        "" \
        "      checks = checksFor { };" \
        "      devShells =" \
        "        let" \
        "          mat = materializationFor { };" \
        "        in" \
        "        mkDevShells { packages = mat.packages; };" \
        "    };" \
        "}" \
        >"$SEED_SRC/flake.nix"
    printf '%s\n' ".direnv/" "result" ".markdownlint.yml" ".yamllint.yml" "lefthook.yml" >"$SEED_SRC/.gitignore"
    printf '%s\n' "jobs:" "  guardrails:" "    uses: pr0d1r2/set-and-setting/.github/workflows/guardrails.yml@main" >"$SEED_SRC/.github/workflows/ci.yml"
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

# ======== custom flake reconciliation (#127) ========

@test "custom flake with extra inputs is reconciled (#127)" {
    printf '%s\n' \
        "{" \
        "  inputs.nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "  inputs.nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "  inputs.my-overlay.url = \"github:example/overlay\";" \
        "  inputs.my-overlay.inputs.nixpkgs.follows = \"nixpkgs\";" \
        "  outputs = { self, nixpkgs, my-overlay, ... }: { };" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"reconcil"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # custom input preserved in reconciled flake
    grep -q 'my-overlay.url' flake.nix
    grep -q 'my-overlay.inputs.nixpkgs.follows' flake.nix
    # custom input in outputs args
    grep -q 'my-overlay,' flake.nix
    # standard infrastructure present
    grep -q 'set-and-setting' flake.nix
    grep -q 'checksFor' flake.nix
}

@test "custom flake with overlays as outputs is reconciled (#127)" {
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
    [ "$status" -eq 0 ]
    [[ "$output" == *"reconcil"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # overlay preserved in reconciled flake
    grep -q 'overlays.default' flake.nix
    # standard infrastructure present
    grep -q 'set-and-setting' flake.nix
    grep -q 'checksFor' flake.nix
}

@test "custom flake with extra outputs is reconciled (#127)" {
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
    [ "$status" -eq 0 ]
    [[ "$output" == *"reconcil"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # custom output preserved
    grep -q 'nixosConfigurations.test' flake.nix
    # standard infrastructure present
    grep -q 'set-and-setting' flake.nix
    grep -q 'checksFor' flake.nix
}

@test "custom flake with inputs + outputs is fully reconciled (#127)" {
    printf '%s\n' \
        "{" \
        "  inputs.nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "  inputs.nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "  inputs.home-manager.url = \"github:nix-community/home-manager\";" \
        "  outputs = { self, nixpkgs, home-manager, ... }: {" \
        "    homeConfigurations.user = home-manager.lib.homeManagerConfiguration {" \
        "      modules = [ ./home.nix ];" \
        "    };" \
        "  };" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"reconcil"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # both custom input and output preserved
    grep -q 'home-manager.url' flake.nix
    grep -q 'home-manager,' flake.nix
    grep -q 'homeConfigurations.user' flake.nix
    # standard infrastructure present
    grep -q 'set-and-setting' flake.nix
    grep -q 'checksFor' flake.nix
    grep -q 'materializationFor' flake.nix
}

@test "un-reconcilable: overlays applied to pkgs emits MIGRATE-FAIL (#127)" {
    printf '%s\n' \
        "{" \
        "  inputs.my-overlay.url = \"github:example/overlay\";" \
        "  outputs = { self, nixpkgs, my-overlay, ... }:" \
        "  let" \
        "    pkgs = import nixpkgs {" \
        "      system = \"x86_64-linux\";" \
        "      overlays = [ my-overlay.overlays.default ];" \
        "    };" \
        "  in { packages.x86_64-linux.default = pkgs.hello; };" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=detect reason=unreconcilable-flake"* ]]
    [[ "$output" == *"overlays applied"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

@test "un-reconcilable: custom outputs not extractable emits MIGRATE-FAIL (#127)" {
    # nixosConfigurations in a string value triggers has_extra_outputs but the
    # brace-counted extractor cannot find a top-level attribute block
    printf '%s\n' \
        "{" \
        "  outputs = { self }: {" \
        "    packages.desc = \"generates nixosConfigurations\";" \
        "  };" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL: stage=detect reason=unreconcilable-flake"* ]]
    [[ "$output" == *"not extractable"* ]]
    [[ "$output" == *"retry: idempotent"* ]]
}

@test "dry-run with custom flake shows reconciliation plan (#127)" {
    printf '%s\n' \
        "{" \
        "  inputs.my-overlay.url = \"github:example/overlay\";" \
        "  outputs = { self }: { };" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    MIGRATE_DRY_RUN=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run plan"* ]]
    [[ "$output" == *"reconcile: flake.nix"* ]]
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

@test "migrate customizes fragments in planted flake.nix (#143)" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    echo "# readme" >README.md
    echo "test: true" >config.yml
    echo 'echo hello' >script.sh
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS: equivalence"* ]]
    [[ "$output" == *"fragments:"* ]]
    # fragments in planted flake.nix match detected content
    grep -q '"base"' flake.nix
    grep -q '"nix"' flake.nix
    grep -q '"markdown"' flake.nix
    grep -q '"yaml"' flake.nix
    grep -q '"shell"' flake.nix
    grep -q '"ascii"' flake.nix
    # "set" excluded (specific to set-and-setting)
    ! grep -q '"set"' flake.nix
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

# ======== #149: overlay-exporting hub repos ========

@test "overlay-exporting hub repo: let-binding is extracted with overlay output (#149)" {
    printf '%s\n' \
        "{" \
        "  inputs = {" \
        "    nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "    nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "    my-src = {" \
        "      url = \"github:example/my-src\";" \
        "      flake = false;" \
        "    };" \
        "  };" \
        "" \
        "  outputs =" \
        "    { self, nixpkgs, my-src, ... }:" \
        "    let" \
        "      myOverlay = final: prev: {" \
        "        my-tool = prev.writeShellApplication {" \
        "          name = \"my-tool\";" \
        "          text = builtins.readFile \"\${my-src}/script.sh\";" \
        "        };" \
        "      };" \
        "    in" \
        "    {" \
        "      overlays.default = myOverlay;" \
        "    };" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"reconcil"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # let-binding preserved (not dangling reference)
    grep -q 'myOverlay = final: prev:' flake.nix
    # let-binding injected exactly once (not at inner let...in blocks)
    [ "$(grep -c 'myOverlay = final: prev:' flake.nix)" -eq 1 ]
    # overlay output preserved
    grep -q 'overlays.default = myOverlay' flake.nix
    # block-style input preserved
    grep -q 'my-src' flake.nix
    # input in output args
    grep -q 'my-src,' flake.nix
    # standard infrastructure present
    grep -q 'set-and-setting' flake.nix
    grep -q 'checksFor' flake.nix
}

# ======== #149: syntax-error repo shapes (input not leaked into outputs) ========

@test "input reference in outputs body not leaked into inputs section (#149)" {
    printf '%s\n' \
        "{" \
        "  inputs = {" \
        "    nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "    nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "    disko.url = \"github:nix-community/disko\";" \
        "    disko.inputs.nixpkgs.follows = \"nixpkgs\";" \
        "  };" \
        "" \
        "  outputs =" \
        "    { self, nixpkgs, disko, ... }:" \
        "    {" \
        "      nixosConfigurations.builder = nixpkgs.lib.nixosSystem {" \
        "        system = \"x86_64-linux\";" \
        "        modules = [" \
        "          disko.nixosModules.disko" \
        "          ./configuration.nix" \
        "        ];" \
        "      };" \
        "    };" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"reconcil"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # disko input declarations preserved in inputs section
    grep -q 'disko.url' flake.nix
    grep -q 'disko.inputs.nixpkgs.follows' flake.nix
    # disko in output args
    grep -q 'disko,' flake.nix
    # nixosConfigurations preserved in outputs
    grep -q 'nixosConfigurations.builder' flake.nix
    grep -q 'disko.nixosModules.disko' flake.nix
    # no stray disko.nixosModules.disko in inputs section
    # (the inputs section ends at the first "};" after "inputs = {")
    local inputs_block
    inputs_block="$(awk '/inputs = \{/{s=1} s{print} s&&/\};/{exit}' flake.nix)"
    echo "$inputs_block" | run ! grep -q 'nixosModules'
    # standard infrastructure present
    grep -q 'set-and-setting' flake.nix
    grep -q 'checksFor' flake.nix
}

@test "block-style input with nixosModules usage does not produce syntax error (#149)" {
    printf '%s\n' \
        "{" \
        "  inputs = {" \
        "    nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "    nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "    disko = {" \
        "      url = \"github:nix-community/disko\";" \
        "      inputs.nixpkgs.follows = \"nixpkgs\";" \
        "    };" \
        "  };" \
        "" \
        "  outputs =" \
        "    { self, nixpkgs, disko, ... }:" \
        "    {" \
        "      nixosConfigurations.builder = nixpkgs.lib.nixosSystem {" \
        "        modules = [ disko.nixosModules.disko ];" \
        "      };" \
        "    };" \
        "}" \
        >flake.nix
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"reconcil"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # block-style input preserved
    grep -q 'disko' flake.nix
    # nixosConfigurations preserved
    grep -q 'nixosConfigurations.builder' flake.nix
    # standard infrastructure present
    grep -q 'set-and-setting' flake.nix
    grep -q 'checksFor' flake.nix
}

# ======== #149: fidelity -- seed template assembles at runtime ========

@test "fidelity: seed template uses runtime assembly (settingHook not store copy)" {
    # Verify the seed template uses settingHook (runtime assembly) not
    # defaultShellHook with cp from store -- ensures lefthook-repo.yml is
    # picked up and fidelity check passes for repos with repo-local checks.
    local seed_flake="$BATS_TEST_DIRNAME/../setting/scaffold/leaf-flake.txt"
    grep -q 'settingHook' "$seed_flake"
    grep -q 'assemble-lefthook.sh' "$seed_flake"
    # must NOT have `cp -f ${mat.files}/lefthook.yml` (store copy)
    run ! grep -q 'mat\.files.*lefthook\.yml' "$seed_flake"
}

# ======== #150: content-aware-leaf archetype ========

@test "content-aware-leaf: packages.default preserved, scaffolding stripped (#150)" {
    # A typical nix-lefthook-yamllint leaf: packages.default = writeShellApplication
    # + nix-lefthook-*-src flake=false inputs (standard CI scaffolding)
    printf '%s\n' \
        "{" \
        "  inputs = {" \
        "    nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "    nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "    nix-lefthook-nixfmt-src = {" \
        "      url = \"github:pr0d1r2/nix-lefthook-nixfmt\";" \
        "      flake = false;" \
        "    };" \
        "    nix-lefthook-statix-src = {" \
        "      url = \"github:pr0d1r2/nix-lefthook-statix\";" \
        "      flake = false;" \
        "    };" \
        "  };" \
        "" \
        "  outputs =" \
        "    { self, nixpkgs, nix-lefthook-nixfmt-src, nix-lefthook-statix-src, ... }:" \
        "    let" \
        "      forAllSystems = f: nixpkgs.lib.genAttrs [ \"x86_64-linux\" ] (s: f s);" \
        "    in" \
        "    {" \
        "      packages.default = nixpkgs.legacyPackages.x86_64-linux.writeShellApplication {" \
        "        name = \"lefthook-yamllint\";" \
        "        text = builtins.readFile ./lefthook-yamllint.sh;" \
        "      };" \
        "    };" \
        "}" \
        >flake.nix
    echo "#!/usr/bin/env bash" >lefthook-yamllint.sh
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"reconcil"* ]]
    [[ "$output" == *"content-aware-leaf"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # leaf product preserved in reconciled flake
    grep -q 'writeShellApplication' flake.nix
    grep -q 'lefthook-yamllint' flake.nix
    grep -q 'default' flake.nix
    # scaffolding inputs NOT in reconciled flake
    run ! grep -q 'nix-lefthook-nixfmt-src' flake.nix
    run ! grep -q 'nix-lefthook-statix-src' flake.nix
    # standard infrastructure present
    grep -q 'set-and-setting' flake.nix
    grep -q 'checksFor' flake.nix
}

@test "content-aware-leaf: leaf with own source input preserves it (#150)" {
    # A leaf that has both scaffolding inputs AND its own source input
    printf '%s\n' \
        "{" \
        "  inputs = {" \
        "    nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "    nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "    nix-lefthook-nixfmt-src = {" \
        "      url = \"github:pr0d1r2/nix-lefthook-nixfmt\";" \
        "      flake = false;" \
        "    };" \
        "    yamllint-src = {" \
        "      url = \"github:example/yamllint\";" \
        "      flake = false;" \
        "    };" \
        "  };" \
        "" \
        "  outputs =" \
        "    { self, nixpkgs, nix-lefthook-nixfmt-src, yamllint-src, ... }:" \
        "    {" \
        "      packages.default = nixpkgs.legacyPackages.x86_64-linux.writeShellApplication {" \
        "        name = \"lefthook-yamllint\";" \
        "        text = builtins.readFile ./lefthook-yamllint.sh;" \
        "      };" \
        "    };" \
        "}" \
        >flake.nix
    echo "#!/usr/bin/env bash" >lefthook-yamllint.sh
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"reconcil"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # leaf product preserved
    grep -q 'writeShellApplication' flake.nix
    grep -q 'lefthook-yamllint' flake.nix
    # own source input preserved (not stripped as scaffolding)
    grep -q 'yamllint-src' flake.nix
    # scaffolding input stripped
    run ! grep -q 'nix-lefthook-nixfmt-src' flake.nix
    # standard infrastructure present
    grep -q 'set-and-setting' flake.nix
    grep -q 'checksFor' flake.nix
}

@test "content-aware-leaf: forAllSystems pattern extracts default (#150)" {
    # Leaf using the forAllSystems pattern for packages
    printf '%s\n' \
        "{" \
        "  inputs = {" \
        "    nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "    nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "    nix-lefthook-nixfmt-src = {" \
        "      url = \"github:pr0d1r2/nix-lefthook-nixfmt\";" \
        "      flake = false;" \
        "    };" \
        "  };" \
        "" \
        "  outputs =" \
        "    { self, nixpkgs, nix-lefthook-nixfmt-src, ... }:" \
        "    let" \
        "      forAllSystems = f: nixpkgs.lib.genAttrs [ \"x86_64-linux\" ] (s: f s);" \
        "    in" \
        "    {" \
        "      packages = forAllSystems (system:" \
        "        let" \
        "          pkgs = nixpkgs.legacyPackages.\${system};" \
        "        in" \
        "        {" \
        "          default = pkgs.writeShellApplication {" \
        "            name = \"lefthook-typos\";" \
        "            text = builtins.readFile ./lefthook-typos.sh;" \
        "          };" \
        "        });" \
        "    };" \
        "}" \
        >flake.nix
    echo "#!/usr/bin/env bash" >lefthook-typos.sh
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"reconcil"* ]]
    [[ "$output" == *"content-aware-leaf"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    # leaf product preserved
    grep -q 'writeShellApplication' flake.nix
    grep -q 'lefthook-typos' flake.nix
    # scaffolding stripped
    run ! grep -q 'nix-lefthook-nixfmt-src' flake.nix
    # standard infrastructure present
    grep -q 'set-and-setting' flake.nix
    grep -q 'checksFor' flake.nix
}

@test "content-aware-leaf: lib false positive does not trigger unreconcilable (#150)" {
    # nixpkgs.lib.genAttrs used to trigger has_extra_outputs via the
    # lib\. grep pattern, causing "custom output blocks not extractable"
    printf '%s\n' \
        "{" \
        "  inputs = {" \
        "    nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "    nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "    nix-lefthook-nixfmt-src = {" \
        "      url = \"github:pr0d1r2/nix-lefthook-nixfmt\";" \
        "      flake = false;" \
        "    };" \
        "  };" \
        "" \
        "  outputs =" \
        "    { self, nixpkgs, nix-lefthook-nixfmt-src, ... }:" \
        "    let" \
        "      forAllSystems = f: nixpkgs.lib.genAttrs [ \"x86_64-linux\" ] (s: f s);" \
        "    in" \
        "    {" \
        "      packages.default = nixpkgs.legacyPackages.x86_64-linux.writeShellApplication {" \
        "        name = \"lefthook-nixfmt\";" \
        "        text = builtins.readFile ./lefthook-nixfmt.sh;" \
        "      };" \
        "    };" \
        "}" \
        >flake.nix
    echo "#!/usr/bin/env bash" >lefthook-nixfmt.sh
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    # must NOT fail with "custom output blocks not extractable"
    [ "$status" -eq 0 ]
    [[ "$output" != *"unreconcilable"* ]]
    [[ "$output" != *"not extractable"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
}

# ======== relic stripping (#151) ========

@test "relic: auto-update.yml stripped from already-referenced repo (#151)" {
    cp -r "$SEED_SRC/." .
    mkdir -p .github/workflows
    echo "name: dead cron" >.github/workflows/auto-update.yml
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=referenced"* ]]
    [[ "$output" == *"stripped relic: .github/workflows/auto-update.yml"* ]]
    [[ "$output" == *"relics stripped"* ]]
    [ ! -f .github/workflows/auto-update.yml ]
    ! git ls-files | grep -q 'auto-update.yml'
}

@test "relic: auto-update.yml stripped during vendored transform (#151)" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    mkdir -p .github/workflows
    echo "vendored ci" >.github/workflows/ci.yml
    echo "name: dead cron" >.github/workflows/auto-update.yml
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"stripped relic: .github/workflows/auto-update.yml"* ]]
    [[ "$output" == *"PASS: equivalence"* ]]
    [ ! -f .github/workflows/auto-update.yml ]
    ! git ls-files | grep -q 'auto-update.yml'
}

@test "relic: auto-update.yml NOT in extra_workflows (not preserved)" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    mkdir -p .github/workflows
    echo "vendored ci" >.github/workflows/ci.yml
    echo "name: dead cron" >.github/workflows/auto-update.yml
    echo "deploy workflow" >.github/workflows/deploy.yml
    _init_repo
    MIGRATE_DETECT_ONLY=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    # deploy is preserved, auto-update is NOT listed as extra
    [[ "$output" == *"extra workflows detected (will preserve): deploy.yml"* ]]
    [[ "$output" != *"auto-update"* ]]
}

@test "relic: dry-run reports auto-update.yml strip (#151)" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    write_vendored_lefthook
    mkdir -p .github/workflows
    echo "name: dead cron" >.github/workflows/auto-update.yml
    _init_repo
    MIGRATE_DRY_RUN=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"strip-relic: .github/workflows/auto-update.yml"* ]]
}

@test "relic: dry-run on referenced repo does NOT delete auto-update.yml (#151)" {
    cp -r "$SEED_SRC/." .
    mkdir -p .github/workflows
    echo "name: dead cron" >.github/workflows/auto-update.yml
    _init_repo
    MIGRATE_DRY_RUN=1 run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run plan for state=referenced"* ]]
    [[ "$output" == *"strip-relic: .github/workflows/auto-update.yml"* ]]
    [ -f .github/workflows/auto-update.yml ]
}

@test "relic: referenced repo without relic is still a clean no-op" {
    cp -r "$SEED_SRC/." .
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"state=referenced"* ]]
    [[ "$output" == *"no-op"* ]]
    [[ "$output" != *"relic"* ]]
}

@test "content-aware-leaf: MIGRATE-FAIL names the archetype (#150)" {
    # A leaf that is unreconcilable for another reason (e.g., overlays applied
    # to pkgs) should still report the archetype in the diagnostic
    printf '%s\n' \
        "{" \
        "  inputs = {" \
        "    nixpkgs-lock.url = \"github:pr0d1r2/nixpkgs-lock\";" \
        "    nixpkgs.follows = \"nixpkgs-lock/nixpkgs\";" \
        "    nix-lefthook-nixfmt-src = {" \
        "      url = \"github:pr0d1r2/nix-lefthook-nixfmt\";" \
        "      flake = false;" \
        "    };" \
        "    my-overlay.url = \"github:example/overlay\";" \
        "  };" \
        "" \
        "  outputs =" \
        "    { self, nixpkgs, nix-lefthook-nixfmt-src, my-overlay, ... }:" \
        "    let" \
        "      pkgs = import nixpkgs {" \
        "        system = \"x86_64-linux\";" \
        "        overlays = [ my-overlay.overlays.default ];" \
        "      };" \
        "    in" \
        "    {" \
        "      packages.default = pkgs.writeShellApplication {" \
        "        name = \"lefthook-nixfmt\";" \
        "        text = builtins.readFile ./lefthook-nixfmt.sh;" \
        "      };" \
        "    };" \
        "}" \
        >flake.nix
    echo "#!/usr/bin/env bash" >lefthook-nixfmt.sh
    write_vendored_lefthook
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MIGRATE-FAIL"* ]]
    [[ "$output" == *"archetype=content-aware-leaf"* ]]
    [[ "$output" == *"overlays applied"* ]]
}

# ======== CHECK_FRAGMENT_MAP (#168) ========

@test "CHECK_FRAGMENT_MAP drives fragment lookup for carry-through (#168)" {
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    nixfmt:" \
        "      run: nixfmt --check {staged_files}" \
        "    custom-tool:" \
        "      run: custom-tool check" \
        >lefthook.yml
    _init_repo
    run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    # nixfmt is in CHECK_FRAGMENT_MAP (nix fragment) -> standard, not carried
    # custom-tool is NOT in CHECK_FRAGMENT_MAP -> repo-local, carried through
    [[ "$output" == *"carried-through: custom-tool"* ]]
    [ -f lefthook-repo.yml ]
    grep -q 'custom-tool:' lefthook-repo.yml
}

@test "CHECK_FRAGMENT_MAP classifies all fragment checks as standard (#168)" {
    # markdownlint and set-skill-extension are lefthook-only checks covered
    # by standard fragments. With FULL_LEFTHOOK="" they are not in the
    # referenced universe, so they appear as "dropped" with a diagnostic
    # citing the standard fragment that covers them.
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    markdownlint:" \
        "      run: markdownlint {staged_files}" \
        "    set-skill-extension:" \
        "      run: set-skill-extension check" \
        >lefthook.yml
    _init_repo
    FULL_LEFTHOOK="" run bash "$MIGRATE_SCRIPT"
    [ "$status" -ne 0 ]
    # both are in CHECK_FRAGMENT_MAP -> standard fragment diagnostics
    [[ "$output" == *"standard fragment \`markdown\`"* ]]
    [[ "$output" == *"standard fragment \`set\`"* ]]
    # none should be classified as repo-local
    [[ "$output" != *"NO standard equivalent"* ]]
}

@test "empty CHECK_FRAGMENT_MAP treats dropped checks as repo-local (#168)" {
    # markdownlint is lefthook-only (not in CHECKS_UNIVERSE). With an empty
    # CHECK_FRAGMENT_MAP it should be classified as repo-local and carried
    # through, rather than diagnosed as a standard-fragment check.
    echo "{ outputs = { self }: { }; }" >flake.nix
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    nixfmt:" \
        "      run: nixfmt --check {staged_files}" \
        "    markdownlint:" \
        "      run: markdownlint {staged_files}" \
        >lefthook.yml
    _init_repo
    # strip FULL_LEFTHOOK so markdownlint is not in the universe
    CHECK_FRAGMENT_MAP="" FULL_LEFTHOOK="" run bash "$MIGRATE_SCRIPT"
    [ "$status" -eq 0 ]
    # markdownlint (not in CHECKS_UNIVERSE, not in empty map) -> repo-local
    [[ "$output" == *"carried-through: markdownlint"* ]]
}
