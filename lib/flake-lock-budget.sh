#!/usr/bin/env bash
set -euo pipefail

lock=${1:-flake.lock}
baseline=${2:-config/lefthook/flake_lock_baseline.yml}

test -f "$lock" || { echo "error: $lock: not found" >&2; exit 1; }
test -f "$baseline" || { echo "error: $baseline: not found" >&2; exit 1; }
jq empty "$lock" 2>/dev/null || { echo "error: $lock: invalid JSON" >&2; exit 1; }

bytes=$(wc -c <"$lock" | tr -d ' ')
nodes=$(jq '.nodes | length' "$lock")
unique=$(jq '[.nodes[] | tojson] | unique | length' "$lock")
ratio=$(awk -v n="$nodes" -v u="$unique" 'BEGIN { printf "%.6f", n / u }')

read_baseline() { sed -n "s/^$1: *//p" "$baseline"; }
base_bytes=$(read_baseline bytes)
base_nodes=$(read_baseline nodes)
base_ratio=$(read_baseline duplication_ratio)
max_bytes=$(read_baseline absolute_max_bytes)
max_nodes=$(read_baseline absolute_max_nodes)
max_ratio=$(read_baseline absolute_max_duplication_ratio)

for value in "$base_bytes" "$base_nodes" "$max_bytes" "$max_nodes"; do
  [[ "$value" =~ ^[1-9][0-9]*$ ]] || { echo "error: invalid integer in $baseline" >&2; exit 1; }
done
for value in "$base_ratio" "$max_ratio"; do
  [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]] || { echo "error: invalid ratio in $baseline" >&2; exit 1; }
done

printf 'bytes=%s nodes=%s unique_nodes=%s duplication_ratio=%s baseline_bytes=%s baseline_nodes=%s baseline_duplication_ratio=%s\n' \
  "$bytes" "$nodes" "$unique" "$ratio" "$base_bytes" "$base_nodes" "$base_ratio"

if [ "$bytes" -gt "$max_bytes" ] || [ "$nodes" -gt "$max_nodes" ]; then
  echo "flake.lock sanity cap exceeded: ${bytes} bytes / ${nodes} nodes (caps ${max_bytes} / ${max_nodes})" >&2
  exit 1
fi
if awk -v actual="$ratio" -v baseline="$base_ratio" -v cap="$max_ratio" 'BEGIN { exit !(actual > baseline || actual > cap) }'; then
  echo "flake.lock duplication ratchet exceeded: $ratio (baseline $base_ratio, cap $max_ratio)" >&2
  exit 1
fi
