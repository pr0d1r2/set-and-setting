# shellcheck shell=bash
# Shared setup and fixture writers for the lib/migrate.sh specs
# (tests/lib/migrate*.bats). setup loads ../git-env (B97).

setup() {
    load ../git-env
    bats_require_minimum_version 1.5.0
    REPO_ROOT="$BATS_TEST_DIRNAME/../.."
    export MIGRATE_SCRIPT="$REPO_ROOT/lib/migrate.sh"
    export FRAGMENTS_DIR="$REPO_ROOT/setting/integrations/lefthook"
    export ASSEMBLE_SCRIPT="$REPO_ROOT/setting/lib/assemble-lefthook.sh"
    export DETECT_SCRIPT="$REPO_ROOT/setting/lib/detect-fragments.sh"
    export CONFIRM_SCRIPT="$REPO_ROOT/lib/confirm.sh"
    export CONFIRM_REV="test-rev"
    export CHECKS_UNIVERSE="actionlint flake-manifest nixfmt statix deadnix shellcheck gitleaks shfmt typos ascii-only unicode-lint editorconfig-checker execute-permissions file-size-check git-conflict-markers git-no-local-paths missing-final-newline nix-no-embedded-shell no-shell-functions trailing-whitespace"
    export CHECK_FRAGMENT_MAP="actionlint=actions gitleaks=base git-conflict-markers=base git-no-local-paths=base execute-permissions=base file-size-check=base trailing-whitespace=base missing-final-newline=base editorconfig-checker=base typos=base nix-flake-check=base flake-manifest=nix nixfmt=nix statix=nix deadnix=nix nix-no-embedded-shell=nix shellcheck=shell shfmt=shell no-shell-functions=shell rubocop=rubocop rspec=rspec reek=reek brakeman=brakeman bundle-audit=bundle-audit ascii-only=ascii unicode-lint=ascii markdownlint=markdown markdownlint-agentic=markdown yamllint=yaml set-skill-extension=set set-skill-size=set set-ref-resolution=set set-bundle-content=set"
    export FRAGMENT_TRIGGERS="base=always active|actions=tracked .github/workflows/*.yml/*.yaml files|nix=tracked *.nix files|shell=tracked *.sh/*.bash files|rubocop=tracked .rubocop.yml or *.gemspec files|rspec=tracked spec/ files or .rspec|reek=tracked .reek.yml|brakeman=tracked config/brakeman.yml|bundle-audit=tracked Gemfile.lock|ascii=always active|markdown=tracked *.md files|yaml=tracked *.yml/*.yaml files|set=tracked set/*.md files"

    # a materialized config bundle (SETTING_SRC)
    SETTING_SRC="$(mktemp -d)"
    echo "markdownlint config" >"$SETTING_SRC/.markdownlint.yml"
    echo "yamllint config" >"$SETTING_SRC/.yamllint.yml"
    export SETTING_SRC

    # a leaf seed (SEED_SRC): thin referenced flake + gitignore + CI caller
    SEED_SRC="$(mktemp -d)"
    mkdir -p "$SEED_SRC/.github/workflows"
    # Use the real leaf seed so migration compatibility tests exercise the
    # current mkConsumerFlake structure and its reconciliation escape hatches.
    cp "$REPO_ROOT/setting/scaffold/leaf-flake.txt" "$SEED_SRC/flake.nix"
    printf '%s\n' ".direnv/" "result" ".markdownlint.yml" ".yamllint.yml" "lefthook.yml" >"$SEED_SRC/.gitignore"
    printf '%s\n' "jobs:" "  guardrails:" "    uses: pr0d1r2/set-and-setting/.github/workflows/guardrails.yml@main" >"$SEED_SRC/.github/workflows/ci.yml"
    export SEED_SRC

    # FULL_LEFTHOOK: assembled from all fragments (command-name universe)
    FULL_DIR="$(mktemp -d)"
    FRAGMENTS="base nix shell rubocop rspec reek brakeman bundle-audit ascii markdown yaml set" out="$FULL_DIR" \
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

_assert_fragment_indent() {
    awk '
        /fragments = \[/ {
            found = 1
            match($0, /^[[:space:]]*/)
            expected = RLENGTH + 2
            if (getline <= 0) exit 1
            match($0, /^[[:space:]]*/)
            exit RLENGTH == expected ? 0 : 1
        }
        END { if (!found) exit 1 }
    ' flake.nix
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
