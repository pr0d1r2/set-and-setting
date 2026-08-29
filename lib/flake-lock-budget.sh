#!/usr/bin/env bash
# Mechanical flake.lock ratchet.  The baseline is deliberately committed: a
# lock refresh may change it only in the same commit as the refreshed lock.
set -euo pipefail

lock=${1:-flake.lock}
baseline=${FLAKE_LOCK_BASELINE:-config/lefthook/flake_lock_baseline.json}
config=${FLAKE_LOCK_BUDGET_CONFIG:-config/lefthook/flake_lock_budget.yml}

if [[ $# -eq 0 && ! -f $lock ]]; then exit 0; fi
[[ -f $lock ]] || {
  echo "error: $lock: not found" >&2
  exit 1
}
jq empty "$lock" >/dev/null 2>&1 || {
  echo "error: $lock: invalid JSON" >&2
  exit 1
}
[[ -f $baseline ]] || {
  echo "error: $baseline: not found" >&2
  exit 1
}

actual=$(jq -r '(.nodes // {}) as $n |
  ([ $n | to_entries[] | (.value.locked // .value.original // {"__node": .key}) | tojson ] | unique | length) as $u |
  {bytes: (input_filename | ""), nodes: ($n|length), unique: $u}' "$lock" |
  jq --argjson bytes "$(wc -c <"$lock")" '.bytes=($bytes|tonumber) | .ratio=(.nodes/.unique)')
# Bytes and node count are informational growth (the PR workflow comments on
# them).  Duplication is the ratchet: it must never increase.
old=$(jq -r .ratio "$baseline")
new=$(jq -r .ratio <<<"$actual")
if awk -v n="$new" -v b="$old" 'BEGIN { exit !(n > b + 1e-9) }'; then
  echo "flake.lock ratchet violation: ratio $new > baseline $old" >&2
  exit 1
fi

max_bytes=$(sed -n 's/^max_bytes: *//p' "$config")
max_nodes=$(sed -n 's/^max_nodes: *//p' "$config")
max_ratio=$(sed -n 's/^max_ratio: *//p' "$config")
bytes=$(jq -r .bytes <<<"$actual")
nodes=$(jq -r .nodes <<<"$actual")
ratio=$(jq -r .ratio <<<"$actual")
if ((bytes > max_bytes)) || ((nodes > max_nodes)) || awk -v n="$ratio" -v m="$max_ratio" 'BEGIN { exit !(n > m) }'; then
  echo "flake.lock sanity cap exceeded: $actual" >&2
  exit 1
fi
echo "flake.lock budget OK: $actual"
