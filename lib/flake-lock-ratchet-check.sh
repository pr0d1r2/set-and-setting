#!/usr/bin/env bash
set -euo pipefail

lock=${FLAKE_LOCK:?FLAKE_LOCK is required}
budget=${FLAKE_LOCK_BUDGET:?FLAKE_LOCK_BUDGET is required}
jq_bin=${JQ_BIN:-jq}

bytes=$(wc -c <"$lock")
nodes=$($jq_bin '.nodes | length' "$lock")
unique=$($jq_bin '[.nodes[] | select(.locked?) | [.locked.owner // "", .locked.repo // ""] | join("/")] | unique | length' "$lock")
((unique > 0)) || {
  echo "FAIL: lock has no identifiable nodes"
  exit 1
}
ratio=$(awk -v n="$nodes" -v u="$unique" 'BEGIN { printf "%.3f", n/u }')

base_bytes=$(sed -n 's/^baseline_bytes: *//p' "$budget")
base_nodes=$(sed -n 's/^baseline_nodes: *//p' "$budget")
base_ratio=$(sed -n 's/^baseline_duplication_ratio: *//p' "$budget")
max_bytes=$(sed -n 's/^max_bytes: *//p' "$budget")
max_nodes=$(sed -n 's/^max_nodes: *//p' "$budget")
max_ratio=$(sed -n 's/^max_duplication_ratio: *//p' "$budget")
threshold=$(sed -n 's/^comment_threshold: *//p' "$budget")

export FLAKE_LOCK_BYTES="$bytes" FLAKE_LOCK_NODES="$nodes" \
  FLAKE_LOCK_DUPLICATION_RATIO="$ratio" FLAKE_LOCK_GROWTH_THRESHOLD="$threshold"

fail=0
if ((bytes > max_bytes)); then
  echo "FAIL: lock is $bytes bytes (sanity cap $max_bytes)"
  fail=1
fi
if ((nodes > max_nodes)); then
  echo "FAIL: lock has $nodes nodes (sanity cap $max_nodes)"
  fail=1
fi
if awk -v actual="$ratio" -v cap="$max_ratio" 'BEGIN { exit !(actual > cap) }'; then
  echo "FAIL: lock duplication ratio $ratio exceeds sanity cap $max_ratio"
  fail=1
fi
if awk -v actual="$ratio" -v base="$base_ratio" 'BEGIN { exit !(actual > base) }'; then
  echo "FAIL: lock duplication ratio $ratio exceeds baseline $base_ratio"
  fail=1
fi

if ((fail)); then exit 1; fi
echo "PASS: lock ${bytes} bytes, ${nodes} nodes, duplication ratio ${ratio}"
if awk -v b="$base_bytes" -v a="$bytes" -v t="$threshold" 'BEGIN { exit !(a > b*(1+t)) }' ||
  awk -v b="$base_nodes" -v a="$nodes" -v t="$threshold" 'BEGIN { exit !(a > b*(1+t)) }'; then
  echo "NOTICE: lock growth crossed the PR comment threshold"
  if [[ ${FLAKE_LOCK_ALLOW_GROWTH_NOTICE:-} != 1 ]]; then exit 2; fi
fi
