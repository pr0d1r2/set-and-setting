#!/usr/bin/env bash
# Reject duplicated foundation pins, poisoned nixpkgs-lock nodes, and cycles
# that appear when revision-pinned lock nodes are collapsed to owner/repo.
set -euo pipefail

lock="${FLAKE_LOCK:-flake.lock}"
[ -f "$lock" ] || {
  echo "error: $lock not found"
  exit 1
}

for repo in nixpkgs nixpkgs-lock set-and-setting; do
  count="$(jq --arg repo "$repo" '[.nodes[] | select(.locked.repo? == $repo)] | length' "$lock")"
  if [ "$count" -gt 1 ]; then
    echo "FAIL: $repo has $count lock nodes; expected at most 1"
    exit 1
  fi
done

poisoned="$(jq '[.nodes[] | select(
    .locked.repo? == "nixpkgs-lock"
    and ((.inputs // {}) | has("set-and-setting"))
)] | length' "$lock")"
if [ "$poisoned" -ne 0 ]; then
  echo "FAIL: $poisoned nixpkgs-lock node(s) input set-and-setting"
  exit 1
fi

edges="$(mktemp)"
trap 'rm -f "$edges"' EXIT
jq -r '
    .nodes as $nodes
    | $nodes
    | to_entries[] as $source
    | ($source.value.locked? // null) as $locked
    | select($locked != null and $locked.owner? != null and $locked.repo? != null)
    | ($locked.owner + "/" + $locked.repo) as $from
    | (($source.value.inputs // {}) | to_entries[] | .value) as $target
    | select($target | type == "string")
    | ($nodes[$target].locked? // null) as $target_locked
    | select($target_locked != null and $target_locked.owner? != null and $target_locked.repo? != null)
    | [$from, ($target_locked.owner + "/" + $target_locked.repo)]
    | @tsv
' "$lock" | sort -u >"$edges"

if [ -s "$edges" ] && ! tsort "$edges" >/dev/null 2>&1; then
  echo "FAIL: owner/repo-collapsed lock graph contains a cycle"
  exit 1
fi

echo "lock-graph: foundation pins are unique, clean, and acyclic"
