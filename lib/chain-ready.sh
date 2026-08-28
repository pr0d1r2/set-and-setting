#!/usr/bin/env bash
# chain-ready.sh -- derive the currently ready GitHub issues.
# Reads all issues once; readiness is derived from dependency prose and states.
set -euo pipefail

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "error: not a git repository" >&2
  exit 1
fi

remote_url="$(git remote get-url origin 2>/dev/null || true)"
if [ -z "$remote_url" ]; then
  echo "error: no origin remote" >&2
  exit 1
fi

repo="$(echo "$remote_url" | sed -E 's|.*github\.com[:/]||; s|\.git$||')"
if ! echo "$repo" | grep -qE '^[^/]+/[^/]+$'; then
  echo "error: invalid origin repository '$repo'" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh CLI not found" >&2
  exit 1
fi

records=$( 
  gh issue list --state all --limit 1000 \
    --json number,state,stateReason,body |
    jq -r --arg repo "$repo" '
      def refs:
        (split(",") | map(capture("(?<ref>(?<remote>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)?#[0-9]+)")));
      def dependencies:
        [ .[]
          | .number as $issue
          | .body // ""
          | split("\n")[]
          | select(test("^Depends[ -]on:[[:space:]]*"; "i"))
          | sub("^Depends[ -]on:[[:space:]]*"; "")
          | refs[] | {issue: $issue, ref: .ref, remote: .remote}
        ];
      . as $issues
      | ($issues | map({key: (.number | tostring), value: .}) | from_entries) as $by_number
      | ($issues | dependencies) as $all_deps
      | ($issues | map(select(.state == "OPEN")))[]
      | . as $issue
      | ([ $all_deps[] | select(.issue == $issue.number) ]) as $deps
      | ([ $deps[]
          | (.remote // $repo) as $target_repo
          | (.ref | capture("(?<number>[0-9]+)$").number | tonumber) as $target_number
          | if $target_repo != $repo then
              "E\tissue #\($issue.number) depends on \(.remote)#\($target_number) in another repository"
            elif ($by_number[($target_number | tostring)] | not) then
              "E\tissue #\($issue.number) depends on missing issue #\($target_number)"
            elif $by_number[($target_number | tostring)].state == "CLOSED" and
              $by_number[($target_number | tostring)].stateReason != "NOT_PLANNED" then
              empty
            else
              "B\tissue #\($issue.number) is blocked by #\($target_number)"
            end
        ] | unique) as $problems
      | if ($problems | length) == 0 then
          "R\t\($issue.number)"
        else $problems[]
        end
    '
)

while IFS=$'\t' read -r kind value; do
  case "$kind" in
    R) echo "$value" ;;
    B|E) echo "$value" >&2 ;;
  esac
done <<<"${records}"
