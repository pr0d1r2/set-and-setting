#!/usr/bin/env bats

setup() {
  root="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$root/config/lefthook"
  cp "$BATS_TEST_DIRNAME/../lib/flake-lock-budget.sh" "$root/check.sh"
  cat >"$root/config/lefthook/baseline.yml" <<'EOF'
bytes: 1
nodes: 10
duplication_ratio: 1.000000
absolute_max_bytes: 10000
absolute_max_nodes: 100
absolute_max_duplication_ratio: 4.000000
EOF
}

@test "growth in bytes and nodes is reported but passes" {
  cat >"$root/flake.lock" <<'EOF'
{"nodes":{"root":{"inputs":{"a":"a","b":"b"}},"a":{"original":"a"},"b":{"original":"b"}}}
EOF
  run "$root/check.sh" "$root/flake.lock" "$root/config/lefthook/baseline.yml"
  [ "$status" -eq 0 ]
  [[ "$output" == *"bytes="*"nodes=3"* ]]
}

@test "duplicated node definitions fail the ratio ratchet" {
  cat >"$root/flake.lock" <<'EOF'
{"nodes":{"root":{},"a":{"original":"x"},"b":{"original":"x"},"c":{"original":"x"},"d":{"original":"x"}}}
EOF
  run "$root/check.sh" "$root/flake.lock" "$root/config/lefthook/baseline.yml"
  [ "$status" -eq 1 ]
  [[ "$output" == *"duplication ratchet exceeded"* ]]
}
