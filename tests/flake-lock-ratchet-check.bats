#!/usr/bin/env bats

setup() {
  TARGET=$(mktemp -d)
  SCRIPT="$BATS_TEST_DIRNAME/../lib/flake-lock-ratchet-check.sh"
  cat >"$TARGET/budget.yml" <<'EOF'
baseline_bytes: 100
baseline_nodes: 2
baseline_duplication_ratio: 1.000
max_bytes: 1000
max_nodes: 20
max_duplication_ratio: 2
comment_threshold: 0.05
EOF
}

teardown() { rm -rf "$TARGET"; }

write_lock() { printf '%s\n' "$1" >"$TARGET/flake.lock"; }

@test "ordinary lock growth passes with a notice" {
  write_lock '{"nodes":{"a":{"locked":{"owner":"o","repo":"a"}},"b":{"locked":{"owner":"o","repo":"b"}}},"root":{}}'
  FLAKE_LOCK="$TARGET/flake.lock" FLAKE_LOCK_BUDGET="$TARGET/budget.yml" FLAKE_LOCK_ALLOW_GROWTH_NOTICE=1 run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"growth crossed"* ]]
}

@test "duplication violates the ratio ratchet" {
  write_lock '{"nodes":{"a":{"locked":{"owner":"o","repo":"a"}},"b":{"locked":{"owner":"o","repo":"a"}},"c":{"locked":{"owner":"o","repo":"a"}}},"root":{}}'
  FLAKE_LOCK="$TARGET/flake.lock" FLAKE_LOCK_BUDGET="$TARGET/budget.yml" run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"duplication ratio"* ]]
}
