#!/usr/bin/env bash
set -euo pipefail
lock=${FLAKE_LOCK:-${1:-flake.lock}}
baseline=${FLAKE_LOCK_BASELINE:-config/lefthook/flake_lock_budget.yml}
[ -f "$lock" ] || {
  echo "FAIL: $lock not found"
  exit 1
}
# A repository that has never RECORDED a baseline is not in breach of one
# (B95). The file holds this repository's own measured metrics, so it cannot be
# shipped to consumers as a default -- and `sync-setting` does not deliver it,
# which means every consumer that picked up this check failed on a file it had
# no way to obtain. The ratchet binds where a baseline exists and says so, out
# loud, where none does.
[ -f "$baseline" ] || {
  echo "SKIP: $baseline not found -- no lock baseline recorded for this repository."
  echo "      To enable it here, write that file with this repository's own"
  echo "      current metrics: baseline_bytes, baseline_nodes,"
  echo "      baseline_duplication_ratio, growth_percent, sanity_max_bytes,"
  echo "      sanity_max_nodes, sanity_max_duplication_ratio."
  exit 0
}
bytes=$(wc -c <"$lock")
nodes=$(jq '.nodes | length' "$lock")
unique_repos=$(jq '[.nodes[] | .locked? | select(.owner? and .repo?) | (.owner + "/" + .repo)] | unique | length' "$lock")
repo_nodes=$(jq '[.nodes[] | select(.locked? and .locked.owner? and .locked.repo?)] | length' "$lock")
duplication_ratio=$((repo_nodes * 1000 / (unique_repos > 0 ? unique_repos : 1)))
base_bytes=$(sed -n 's/^baseline_bytes: *//p' "$baseline")
base_nodes=$(sed -n 's/^baseline_nodes: *//p' "$baseline")
base_ratio=$(sed -n 's/^baseline_duplication_ratio: *//p' "$baseline")
max_bytes=$(sed -n 's/^sanity_max_bytes: *//p' "$baseline")
max_nodes=$(sed -n 's/^sanity_max_nodes: *//p' "$baseline")
max_ratio=$(sed -n 's/^sanity_max_duplication_ratio: *//p' "$baseline")
growth_percent=$(sed -n 's/^growth_percent: *//p' "$baseline")
for name in base_bytes base_nodes base_ratio max_bytes max_nodes max_ratio growth_percent; do
  [ -n "${!name}" ] || {
    echo "FAIL: missing $name in $baseline"
    exit 1
  }
done
ratchet_bytes=$((base_bytes + ((base_bytes * growth_percent + 99) / 100)))
ratchet_nodes=$((base_nodes + ((base_nodes * growth_percent + 99) / 100)))
ratchet_ratio=$((base_ratio + ((base_ratio * growth_percent + 99) / 100)))
printf 'lock-budget: bytes=%s nodes=%s duplication_ratio=%s.%03d baseline=%s/%s/%s.%03d\n' "$bytes" "$nodes" "$((duplication_ratio / 1000))" "$((duplication_ratio % 1000))" "$base_bytes" "$base_nodes" "$((base_ratio / 1000))" "$((base_ratio % 1000))"
fail=0
for check in "bytes:$bytes:$ratchet_bytes" "nodes:$nodes:$ratchet_nodes" "duplication_ratio:$duplication_ratio:$ratchet_ratio"; do
  IFS=: read -r name actual allowed <<<"$check"
  if [ "$actual" -gt "$allowed" ]; then
    echo "FAIL: $name $actual exceeds ratchet $allowed"
    fail=1
  fi
done
[ "$bytes" -le "$max_bytes" ] || {
  echo "FAIL: bytes $bytes exceeds sanity cap $max_bytes"
  fail=1
}
[ "$nodes" -le "$max_nodes" ] || {
  echo "FAIL: nodes $nodes exceeds sanity cap $max_nodes"
  fail=1
}
[ "$duplication_ratio" -le "$max_ratio" ] || {
  echo "FAIL: duplication_ratio $duplication_ratio exceeds sanity cap $max_ratio"
  fail=1
}
exit "$fail"
