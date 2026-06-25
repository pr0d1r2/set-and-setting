#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for setting/lib/assemble-lefthook.sh -- assembles lefthook.yml
# from integration fragments by merging remotes + pre-commit + pre-push.

setup() {
    bats_require_minimum_version 1.5.0
    FRAGMENTS_DIR="$(mktemp -d)"
    export out
    out="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/assemble-lefthook.sh"

    cat >"$FRAGMENTS_DIR/base.yml" <<'EOF'
---
remotes:
  - git_url: https://github.com/example/hook-a
    ref: main
    configs:
      - lefthook-remote.yml
  - git_url: https://github.com/example/hook-b
    ref: main
    configs:
      - lefthook-remote.yml
EOF

    cat >"$FRAGMENTS_DIR/nix.yml" <<'EOF'
---
remotes:
  - git_url: https://github.com/example/hook-nix
    ref: main
    configs:
      - lefthook-remote.yml
EOF

    cat >"$FRAGMENTS_DIR/shell.yml" <<'EOF'
---
remotes:
  - git_url: https://github.com/example/hook-shell
    ref: main
    configs:
      - lefthook-remote.yml
EOF

    cat >"$FRAGMENTS_DIR/ascii.yml" <<'EOF'
---
remotes:
  - git_url: https://github.com/example/hook-ascii
    ref: main
    configs:
      - lefthook-remote.yml

pre-commit:
  parallel: true
  commands:
    ascii-check:
      glob: "*.nix"
      run: lefthook-ascii {staged_files}

pre-push:
  parallel: true
  commands:
    ascii-check:
      glob: "*.nix"
      run: lefthook-ascii {push_files}
EOF

    cat >"$FRAGMENTS_DIR/markdown.yml" <<'EOF'
---
remotes:
  - git_url: https://github.com/example/hook-md
    ref: main
    configs:
      - lefthook-remote.yml

pre-commit:
  parallel: true
  commands:
    mdlint:
      glob: "*.md"
      run: lefthook-mdlint {staged_files}

pre-push:
  parallel: true
  commands:
    mdlint:
      glob: "*.md"
      run: lefthook-mdlint {push_files}
EOF

    cat >"$FRAGMENTS_DIR/yaml.yml" <<'EOF'
---
remotes:
  - git_url: https://github.com/example/hook-yaml
    ref: main
    configs:
      - lefthook-remote.yml

pre-commit:
  parallel: true
  commands:
    yamllint:
      glob: "*.yml"
      run: lefthook-yamllint {staged_files}

pre-push:
  parallel: true
  commands:
    yamllint:
      glob: "*.yml"
      run: lefthook-yamllint {push_files}
EOF

    export FRAGMENTS_DIR
}

teardown() {
    rm -rf "$FRAGMENTS_DIR" "$out"
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

@test "merges all remotes from all fragments" {
    bash "$SCRIPT"
    grep -c 'git_url:' "$out/lefthook.yml" | grep -q '^7$'
}

@test "remotes appear in fragment order" {
    bash "$SCRIPT"
    first_remote="$(grep 'git_url:' "$out/lefthook.yml" | head -1)"
    [[ "$first_remote" == *"hook-a"* ]]
    last_remote="$(grep 'git_url:' "$out/lefthook.yml" | tail -1)"
    [[ "$last_remote" == *"hook-yaml"* ]]
}

@test "has pre-commit section with parallel and commands" {
    bash "$SCRIPT"
    grep -q '^pre-commit:' "$out/lefthook.yml"
    grep -q '  parallel: true' "$out/lefthook.yml"
    grep -q '  commands:' "$out/lefthook.yml"
}

@test "pre-commit merges commands from all fragments" {
    bash "$SCRIPT"
    grep -q 'ascii-check:' "$out/lefthook.yml"
    grep -q 'mdlint:' "$out/lefthook.yml"
    grep -q 'yamllint:' "$out/lefthook.yml"
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
}

@test "fragments without commands do not add empty sections" {
    rm "$FRAGMENTS_DIR/ascii.yml" "$FRAGMENTS_DIR/markdown.yml" "$FRAGMENTS_DIR/yaml.yml"
    cat >"$FRAGMENTS_DIR/ascii.yml" <<'EOF'
---
remotes:
  - git_url: https://github.com/example/hook-ascii
    ref: main
    configs:
      - lefthook-remote.yml
EOF
    cat >"$FRAGMENTS_DIR/markdown.yml" <<'EOF'
---
remotes:
  - git_url: https://github.com/example/hook-md
    ref: main
    configs:
      - lefthook-remote.yml
EOF
    cat >"$FRAGMENTS_DIR/yaml.yml" <<'EOF'
---
remotes:
  - git_url: https://github.com/example/hook-yaml
    ref: main
    configs:
      - lefthook-remote.yml
EOF
    bash "$SCRIPT"
    ! grep -q '^pre-commit:' "$out/lefthook.yml"
    ! grep -q '^pre-push:' "$out/lefthook.yml"
}

@test "assembles real fragments from setting/integrations/lefthook" {
    local real_dir
    real_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/setting/integrations/lefthook"
    FRAGMENTS_DIR="$real_dir"
    export FRAGMENTS_DIR
    bash "$SCRIPT"
    [ -f "$out/lefthook.yml" ]
    grep -q 'nix-lefthook-trailing-whitespace' "$out/lefthook.yml"
    grep -q 'nix-lefthook-nixfmt' "$out/lefthook.yml"
    grep -q 'nix-lefthook-yamllint' "$out/lefthook.yml"
    grep -q '^pre-commit:' "$out/lefthook.yml"
    grep -q '^pre-push:' "$out/lefthook.yml"
    grep -q 'markdownlint:' "$out/lefthook.yml"
    grep -q 'ascii-only:' "$out/lefthook.yml"
    grep -q 'yamllint:' "$out/lefthook.yml"
}
