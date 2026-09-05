#!/usr/bin/env bash
set -euo pipefail
lock=${FLAKE_LOCK:-flake.lock}
baseline=${FLAKE_LOCK_BASELINE:-config/lefthook/flake_lock_budget.yml}
[ -f "$lock" ] || { echo "FAIL: $lock not found"; exit 1; }
[ -f "$baseline" ] || { echo "FAIL: $baseline not found"; exit 1; }
bytes=$(wc -c <"$lock")
nodes=$(jq '.nodes | length' "$lock")
unique_repos=$(jq '[.nodes[] | .locked? | select(.owner? and .repo?) | (.owner + "/" + .repo)] | unique | length' "$lock")
repo_nodes=$(jq '[.nodes[] | select(.locked? and .locked.owner? and .locked.repo?)] | length' "$lock")
duplication_ratio=$((repo_nodes * 1000 / (unique_repos > 0 ? unique_repos : 1)))
value() { sed -n "s/^$1: *//p" "$baseline"; }
base_bytes=$(value baseline_bytes); base_nodes=$(value baseline_nodes); base_ratio=$(value baseline_duplication_ratio)
max_bytes=$(value sanity_max_bytes); max_nodes=$(value sanity_max_nodes); max_ratio=$(value sanity_max_duplication_ratio); growth_percent=$(value growth_percent)
for name in base_bytes base_nodes base_ratio max_bytes max_nodes max_ratio growth_percent; do
    [ -n "${!name}" ] || { echo "FAIL: missing $name in $baseline"; exit 1; }
done
limit() { echo $(( $1 + (($1 * growth_percent + 99) / 100) )); }
ratchet_bytes=$(limit "$base_bytes"); ratchet_nodes=$(limit "$base_nodes"); ratchet_ratio=$((base_ratio + ((base_ratio * growth_percent + 99) / 100)))
printf 'lock-budget: bytes=%s nodes=%s duplication_ratio=%s.%03d baseline=%s/%s/%s.%03d\n' "$bytes" "$nodes" "$((duplication_ratio / 1000))" "$((duplication_ratio % 1000))" "$base_bytes" "$base_nodes" "$((base_ratio / 1000))" "$((base_ratio % 1000))"
fail=0
for check in "bytes:$bytes:$ratchet_bytes" "nodes:$nodes:$ratchet_nodes" "duplication_ratio:$duplication_ratio:$ratchet_ratio"; do
    IFS=: read -r name actual allowed <<<"$check"
    if [ "$actual" -gt "$allowed" ]; then echo "FAIL: $name $actual exceeds ratchet $allowed"; fail=1; fi
done
[ "$bytes" -le "$max_bytes" ] || { echo "FAIL: bytes $bytes exceeds sanity cap $max_bytes"; fail=1; }
[ "$nodes" -le "$max_nodes" ] || { echo "FAIL: nodes $nodes exceeds sanity cap $max_nodes"; fail=1; }
[ "$duplication_ratio" -le "$max_ratio" ] || { echo "FAIL: duplication_ratio $duplication_ratio exceeds sanity cap $max_ratio"; fail=1; }
exit "$fail"
